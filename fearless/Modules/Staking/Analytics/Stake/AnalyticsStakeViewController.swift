import UIKit
import SoraFoundation
import SoraUI

final class AnalyticsStakeViewController:
    AnalyticsRewardsBaseViewController<
        AnalyticsRewardsViewModel,
        AnalyticsStakeHeaderView,
        AnalyticsStakePresenter
    >, AnalyticsStakeViewProtocol {
    override func viewDidLoad() {
        super.viewDidLoad()

        rootView.headerView.chartView.chartDelegate = self
    }

    var localizedTitle: LocalizableResource<String> {
        LocalizableResource { locale in
            R.string.localizable.stakingStake(preferredLanguages: locale.rLanguages)
        }
    }

    func reload(viewState: AnalyticsViewState<AnalyticsRewardsViewModel>) {
        self.viewState = viewState

        switch viewState {
        case .loading:
            if let refreshControl = rootView.tableView.refreshControl, !refreshControl.isRefreshing {
                refreshControl.programaticallyBeginRefreshing(in: rootView.tableView)
            }
        case let .loaded(viewModel):
            rootView.tableView.refreshControl?.endRefreshing()
            rootView.headerView.bind(
                summaryViewModel: viewModel.summaryViewModel,
                chartData: viewModel.chartData,
                selectedPeriod: viewModel.selectedPeriod
            )
            rootView.tableView.reloadData()
        case .error:
            rootView.tableView.refreshControl?.endRefreshing()
        }
        reloadEmptyState(animated: true)
    }
}

extension AnalyticsStakeViewController: FWChartViewDelegate {
    func didSelectXValue(_ value: Double) {
        guard case let .loaded(viewModel) = viewState else {
            return
        }
        let summary = viewModel.chartData.summary[Int(value)]
        rootView.headerView.bind(summaryViewModel: summary)
    }

    func didUnselect() {
        guard case let .loaded(viewModel) = viewState else {
            return
        }
        let summary = viewModel.summaryViewModel
        rootView.headerView.bind(summaryViewModel: summary)
    }
}
