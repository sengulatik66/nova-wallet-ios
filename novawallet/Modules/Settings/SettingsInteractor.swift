import Foundation
import SoraKeystore
import IrohaCrypto
import RobinHood

enum ProfileInteractorError: Error {
    case noSelectedAccount
}

final class SettingsInteractor {
    weak var presenter: SettingsInteractorOutputProtocol?

    let selectedWalletSettings: SelectedWalletSettings
    let settingsManager: SettingsManagerProtocol
    let eventCenter: EventCenterProtocol
    let biometryAuth: BiometryAuthProtocol
    let walletConnect: WalletConnectDelegateInputProtocol
    let walletNotificationService: WalletNotificationServiceProtocol
    let pushNotificationsSettingsProviderFactory: PushNotificationsSettingsProviderFactoryProtocol
    let pushNotificationsSettingsProvider: AnySingleValueProvider<PushSettings?>?
    
    init(
        selectedWalletSettings: SelectedWalletSettings,
        eventCenter: EventCenterProtocol,
        walletConnect: WalletConnectDelegateInputProtocol,
        currencyManager: CurrencyManagerProtocol,
        settingsManager: SettingsManagerProtocol,
        biometryAuth: BiometryAuthProtocol,
        walletNotificationService: WalletNotificationServiceProtocol,
        pushNotificationsSettingsProviderFactory: PushNotificationsSettingsProviderFactoryProtocol
    ) {
        self.selectedWalletSettings = selectedWalletSettings
        self.eventCenter = eventCenter
        self.settingsManager = settingsManager
        self.biometryAuth = biometryAuth
        self.walletConnect = walletConnect
        self.walletNotificationService = walletNotificationService
        self.pushNotificationsSettingsProviderFactory = pushNotificationsSettingsProviderFactory
        self.currencyManager = currencyManager
    }

    private func provideUserSettings() {
        do {
            guard let wallet = selectedWalletSettings.value else {
                throw ProfileInteractorError.noSelectedAccount
            }
            presenter?.didReceive(wallet: wallet)
        } catch {
            presenter?.didReceiveUserDataProvider(error: error)
        }

        provideSecuritySettings()
    }

    private func provideSecuritySettings() {
        let biometrySettings: BiometrySettings = .create(
            from: biometryAuth.supportedBiometryType,
            settingsManager: settingsManager
        )
        let pinConfirmationEnabled = settingsManager.pinConfirmationEnabled ?? false

        DispatchQueue.main.async {
            self.presenter?.didReceive(biometrySettings: biometrySettings)
            self.presenter?.didReceive(pinConfirmationEnabled: pinConfirmationEnabled)
        }
    }

    private func provideWalletConnectSessionsCount() {
        let count = walletConnect.getSessionsCount()

        presenter?.didReceiveWalletConnect(sessionsCount: count)
    }
    
    private func subscribeToPushNotificationsSettings() {
        pushNotificationsSettingsProvider?.addObserver(self, deliverOn: .main) { changes in
            if let update = changes.reduceToLastChange() {
                self?.presenter?.didReceive(pushNotificationsSettings: update)
            }
        } failing: { [weak self] error in
            self?.presenter?.didReceive(error: .pushNotifications(error))
        }
    }
}

extension SettingsInteractor: SettingsInteractorInputProtocol {
    func setup() {
        eventCenter.add(observer: self, dispatchIn: .main)
        walletConnect.add(delegate: self)

        provideUserSettings()
        provideWalletConnectSessionsCount()
        applyCurrency()
        subscribeToPushNotificationsSettings()

        walletNotificationService.hasUpdatesObservable.addObserver(
            with: self,
            sendStateOnSubscription: true
        ) { [weak self] _, newState in
            self?.presenter?.didReceiveWalletsState(hasUpdates: newState)
        }
    }

    func updateBiometricAuthSettings(isOn: Bool) {
        if isOn,
           biometryAuth.availableBiometryType == .none,
           biometryAuth.supportedBiometryType != .none {
            presenter?.didReceive(error: .biometryAuthAndSystemSettingsOutOfSync)
        }

        settingsManager.biometryEnabled = isOn
        provideSecuritySettings()
    }

    func updatePinConfirmationSettings(isOn: Bool) {
        settingsManager.pinConfirmationEnabled = isOn
        provideSecuritySettings()
    }

    func connectWalletConnect(uri: String) {
        walletConnect.connect(uri: uri) { [weak self] optError in
            if let error = optError {
                self?.presenter?.didReceive(error: .walletConnectFailed(error))
            }
        }
    }
}

extension SettingsInteractor: EventVisitorProtocol {
    func processSelectedAccountChanged(event _: SelectedAccountChanged) {
        provideUserSettings()
    }

    func processSelectedUsernameChanged(event _: SelectedUsernameChanged) {
        provideUserSettings()
    }
}

extension SettingsInteractor: WalletConnectDelegateOutputProtocol {
    func walletConnectDidChangeSessions() {
        provideWalletConnectSessionsCount()
    }
}

extension SettingsInteractor: SelectedCurrencyDepending {
    func applyCurrency() {
        guard let presenter = presenter,
              let currencyManager = self.currencyManager else {
            return
        }

        presenter.didReceive(currencyCode: currencyManager.selectedCurrency.code)
    }
}
