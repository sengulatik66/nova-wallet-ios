import UIKit
import SoraFoundation

final class WalletSelectionViewController: WalletsListViewController<WalletSelectionTableViewCell> {

    var presenter: WalletSelectionPresenterProtocol? { basePresenter as? WalletSelectionPresenterProtocol }

    init(presenter: WalletSelectionPresenterProtocol, localizationManager: LocalizationManagerProtocol) {
        super.init(basePresenter: presenter, localizationManager: localizationManager)
    }

    override func setupLocalization() {
        title = R.string.localizable.commonSelectWallet(preferredLanguages: selectedLocale.rLanguages)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        presenter?.selectItem(at: indexPath.row, section: indexPath.section)
    }

    @objc private func actionSettings() {
        presenter?.activateSettings()
    }
}
