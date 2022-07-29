import Foundation
import UIKit

final class AssetListWireframe: AssetListWireframeProtocol {
    let walletUpdater: WalletDetailsUpdating

    init(walletUpdater: WalletDetailsUpdating) {
        self.walletUpdater = walletUpdater
    }

    func showAssetDetails(from view: AssetListViewProtocol?, chain: ChainModel, asset: AssetModel) {
        guard let context = try? WalletContextFactory().createContext(for: chain, asset: asset) else {
            return
        }

        let assetId = ChainAssetId(chainId: chain.chainId, assetId: asset.assetId).walletId

        guard let navigationController = view?.controller.navigationController else {
            return
        }

        try? context.createAssetDetails(for: assetId, in: navigationController)

        walletUpdater.context = context
    }

    func showAssetsManage(from view: AssetListViewProtocol?) {
        guard let assetsManageView = AssetsManageViewFactory.createView() else {
            return
        }

        let navigationController = FearlessNavigationController(
            rootViewController: assetsManageView.controller
        )

        view?.controller.present(navigationController, animated: true, completion: nil)
    }

    func showAssetsSearch(
        from view: AssetListViewProtocol?,
        initState: AssetListInitState,
        delegate: AssetsSearchDelegate
    ) {
        guard let assetsSearchView = AssetsSearchViewFactory.createView(for: initState, delegate: delegate) else {
            return
        }

        assetsSearchView.controller.modalTransitionStyle = .crossDissolve
        assetsSearchView.controller.modalPresentationStyle = .fullScreen

        view?.controller.present(assetsSearchView.controller, animated: true, completion: nil)
    }

    func showNfts(from view: AssetListViewProtocol?) {
        guard let nftListView = NftListViewFactory.createView() else {
            return
        }

        nftListView.controller.hidesBottomBarWhenPushed = true
        view?.controller.navigationController?.pushViewController(nftListView.controller, animated: true)
    }
}