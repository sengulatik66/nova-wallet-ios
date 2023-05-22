import Foundation
import SoraFoundation
import CommonWallet
import BigInt

protocol StakingMainViewProtocol: ControllerBackedProtocol, Localizable {
    func didReceive(viewModel: StakingMainViewModel)
    func didRecieveNetworkStakingInfo(viewModel: LocalizableResource<NetworkStakingInfoViewModel>?)
    func didReceiveStakingState(viewModel: StakingViewState)
    func expandNetworkInfoView(_ isExpanded: Bool)
    func didReceiveStatics(viewModel: StakingMainStaticViewModelProtocol)
    func didEditRewardFilters()
}

protocol StakingMainPresenterProtocol: AnyObject {
    func setup()
    func performAssetSelection()
    func performMainAction()
    func performAccountAction()
    func performRewardInfoAction()
    func performChangeValidatorsAction()
    func performSetupValidatorsForBondedAction()
    func performStakeMoreAction()
    func performRedeemAction()
    func performRebondAction()
    func performRebag()
    func networkInfoViewDidChangeExpansion(isExpanded: Bool)
    func performManageAction(_ action: StakingManageOption)
    func selectPeriod()
}

protocol StakingMainInteractorInputProtocol: AnyObject {
    func setup()
    func saveNetworkInfoViewExpansion(isExpanded: Bool)
    func save(chainAsset: ChainAsset)
    func save(filter: StakingRewardFiltersPeriod)
}

protocol StakingMainInteractorOutputProtocol: AnyObject {
    func didReceiveAccountBalance(_ assetBalance: AssetBalance?)
    func didReceiveSelectedAccount(_ metaAccount: MetaAccountModel)
    func didReceiveStakingSettings(_ stakingSettings: StakingAssetSettings)
    func didReceiveExpansion(_ isExpanded: Bool)
    func didReceiveError(_ error: Error)
    func didReceiveRewardFilter(_ filter: StakingRewardFiltersPeriod)
}

protocol StakingMainWireframeProtocol: AlertPresentable, ErrorPresentable, StakingErrorPresentable,
    WalletSwitchPresentable, NoAccountSupportPresentable {
    func showChainAssetSelection(
        from view: StakingMainViewProtocol?,
        selectedChainAssetId: ChainAssetId?,
        delegate: AssetSelectionDelegate
    )

    func showWalletDetails(from view: ControllerBackedProtocol?, wallet: MetaAccountModel)
    func showPeriodSelection(
        from view: ControllerBackedProtocol?,
        initialState: StakingRewardFiltersPeriod?,
        delegate: StakingRewardFiltersDelegate,
        completion: @escaping () -> Void
    )
}

protocol StakingMainViewFactoryProtocol: AnyObject {
    static func createView() -> StakingMainViewProtocol?
}

protocol StakingMainChildPresenterProtocol: AnyObject {
    func setup()
    func performMainAction()
    func performRewardInfoAction()
    func performChangeValidatorsAction()
    func performSetupValidatorsForBondedAction()
    func performStakeMoreAction()
    func performRedeemAction()
    func performRebondAction()
    func performRebag()
    func performManageAction(_ action: StakingManageOption)
    func selectPeriod(_ period: StakingRewardFiltersPeriod)
}
