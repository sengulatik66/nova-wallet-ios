import Foundation
import SoraFoundation
import BigInt

protocol StakingDashboardViewModelFactoryProtocol {
    func createActiveStakingViewModel(
        for model: StakingDashboardItemModel,
        locale: Locale
    ) -> StakingDashboardEnabledViewModel

    func createInactiveStakingViewModel(
        for model: StakingDashboardItemModel,
        locale: Locale
    ) -> StakingDashboardDisabledViewModel

    func createViewModel(
        from model: StakingDashboardModel,
        locale: Locale
    ) -> StakingDashboardViewModel
}

final class StakingDashboardViewModelFactory {
    let networkViewModelFactory: NetworkViewModelFactoryProtocol
    let priceAssetInfoFactory: PriceAssetInfoFactoryProtocol
    let assetFormatterFactory: AssetBalanceFormatterFactoryProtocol
    let estimatedEarningsFormatter: LocalizableResource<NumberFormatter>

    init(
        assetFormatterFactory: AssetBalanceFormatterFactoryProtocol,
        priceAssetInfoFactory: PriceAssetInfoFactoryProtocol,
        networkViewModelFactory: NetworkViewModelFactoryProtocol,
        estimatedEarningsFormatter: LocalizableResource<NumberFormatter>
    ) {
        self.assetFormatterFactory = assetFormatterFactory
        self.priceAssetInfoFactory = priceAssetInfoFactory
        self.networkViewModelFactory = networkViewModelFactory
        self.estimatedEarningsFormatter = estimatedEarningsFormatter
    }

    private func createEstimatedEarnings(
        from value: Decimal?,
        isSyncing: Bool,
        locale: Locale
    ) -> LoadableViewModelState<String> {
        guard let value = value else {
            return .loading
        }

        guard let valueString = estimatedEarningsFormatter.value(for: locale).stringFromDecimal(value) else {
            return .loading
        }

        return isSyncing ? .cached(value: valueString) : .loaded(value: valueString)
    }

    private func createAmount(
        for value: BigUInt?,
        priceData: PriceData?,
        assetDisplayInfo: AssetBalanceDisplayInfo,
        isSyncing: Bool,
        locale: Locale
    ) -> LoadableViewModelState<BalanceViewModelProtocol> {
        guard
            let value = value,
            let decimalValue = Decimal.fromSubstrateAmount(value, precision: assetDisplayInfo.assetPrecision) else {
            return .loading
        }

        let balanceViewModelFactory = BalanceViewModelFactory(
            targetAssetInfo: assetDisplayInfo,
            priceAssetInfoFactory: priceAssetInfoFactory,
            formatterFactory: assetFormatterFactory
        )

        let viewModel = balanceViewModelFactory.balanceFromPrice(
            decimalValue,
            priceData: priceData ?? PriceData.zero()
        ).value(for: locale)

        return isSyncing ? .cached(value: viewModel) : .loaded(value: viewModel)
    }

    private func createStakingStatus(
        for model: StakingDashboardItemModel
    ) -> LoadableViewModelState<StakingDashboardEnabledViewModel.Status> {
        guard let dashboardItem = model.dashboardItem else {
            return .loading
        }

        let state = StakingDashboardEnabledViewModel.Status(dashboardItem: dashboardItem)
        return model.hasAnySync ? .cached(value: state) : .loaded(value: state)
    }
}

extension StakingDashboardViewModelFactory: StakingDashboardViewModelFactoryProtocol {
    func createActiveStakingViewModel(
        for model: StakingDashboardItemModel,
        locale: Locale
    ) -> StakingDashboardEnabledViewModel {
        let chainAsset = model.stakingOption.chainAsset
        let assetDisplayInfo = chainAsset.assetDisplayInfo

        let networkViewModel = networkViewModelFactory.createViewModel(
            from: chainAsset.chain
        )

        let estimatedEarnings = createEstimatedEarnings(
            from: model.dashboardItem?.maxApy,
            isSyncing: model.isOffchainSync,
            locale: locale
        )

        let totalRewards = createAmount(
            for: model.dashboardItem?.totalRewards ?? 0,
            priceData: model.price,
            assetDisplayInfo: assetDisplayInfo,
            isSyncing: model.isOffchainSync,
            locale: locale
        )

        let yourStake = createAmount(
            for: model.dashboardItem?.stake,
            priceData: model.price,
            assetDisplayInfo: assetDisplayInfo,
            isSyncing: model.isOnchainSync,
            locale: locale
        )

        let status = createStakingStatus(for: model)

        let network: LoadableViewModelState<NetworkViewModel> = model.hasAnySync ?
            .cached(value: networkViewModel) : .loaded(value: networkViewModel)

        return .init(
            networkViewModel: network,
            totalRewards: totalRewards,
            status: status,
            yourStake: yourStake,
            estimatedEarnings: estimatedEarnings
        )
    }

    func createInactiveStakingViewModel(
        for model: StakingDashboardItemModel,
        locale: Locale
    ) -> StakingDashboardDisabledViewModel {
        let chainAsset = model.stakingOption.chainAsset
        let assetDisplayInfo = chainAsset.assetDisplayInfo

        let networkViewModel = networkViewModelFactory.createViewModel(
            from: chainAsset.chain
        )

        let estimatedEarnings = createEstimatedEarnings(
            from: model.dashboardItem?.maxApy,
            isSyncing: model.isOffchainSync,
            locale: locale
        )

        let balance = createAmount(
            for: model.balance?.freeInPlank,
            priceData: model.price,
            assetDisplayInfo: assetDisplayInfo,
            isSyncing: false,
            locale: locale
        ).value?.amount

        return .init(
            networkViewModel: networkViewModel,
            estimatedEarnings: estimatedEarnings,
            balance: balance
        )
    }

    func createViewModel(
        from model: StakingDashboardModel,
        locale: Locale
    ) -> StakingDashboardViewModel {
        let activeViewModels = model.active.map {
            createActiveStakingViewModel(
                for: $0,
                locale: locale
            )
        }

        let inactiveViewModels = model.inactive.map {
            createInactiveStakingViewModel(
                for: $0,
                locale: locale
            )
        }

        let isSyncing = model.active.isEmpty && model.inactive.isEmpty && model.more.isEmpty

        return .init(
            active: activeViewModels,
            inactive: inactiveViewModels,
            hasMoreOptions: true,
            isSyncing: isSyncing
        )
    }
}
