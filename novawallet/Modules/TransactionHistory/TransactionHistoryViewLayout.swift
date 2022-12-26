import UIKit
import SnapKit
import SoraUI
import CommonWallet

final class TransactionHistoryViewLayout: UIView {
    private(set) var titleLeft: Constraint?
    private(set) var headerTop: Constraint?
    private(set) var headerHeight: Constraint?

    let backgroundView: WalletHistoryBackgroundView = {
        let backgroundView = WalletHistoryBackgroundView()
        let cornerCut: UIRectCorner = [.topLeft, .topRight]
        backgroundView.fullBackgroundView.cornerCut = cornerCut
        backgroundView.minimizedBackgroundView.cornerCut = cornerCut
        return backgroundView
    }()

    let filterIcon = R.image.iconFilter()?.tinted(with: R.color.colorIconPrimary()!)
    let closeIcon = R.image.iconClose()?.tinted(with: R.color.colorIconPrimary()!)

    lazy var filterButton: RoundedButton = .create {
        $0.applyIconStyle()
        $0.imageWithTitleView?.iconImage = filterIcon
    }

    lazy var closeButton: RoundedButton = .create {
        $0.applyIconStyle()
        $0.imageWithTitleView?.iconImage = closeIcon
    }

    let pageLoadingView: PageLoadingView = .create {
        $0.verticalMargin = Constants.loadingViewMargin
        let size = $0.intrinsicContentSize
        $0.frame = CGRect(origin: .zero, size: size)
    }

    lazy var tableView: UITableView = .create {
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.contentInset = .init(top: 0, left: 0, bottom: 16, right: 0)
        $0.tableFooterView = pageLoadingView
        $0.isScrollEnabled = true
    }

    let titleLabel = UILabel(style: .init(
        textColor: R.color.colorTextPrimary()!,
        font: .semiBoldSubheadline
    ))
    let headerView: UIView = .create {
        $0.backgroundColor = .clear
    }

    let contentView: UIView = .create {
        $0.backgroundColor = .clear
    }

    let panIndicatorView: RoundedView = .create {
        $0.cornerRadius = 2.5
        $0.fillColor = R.color.colorPullIndicator()!
        $0.shadowOpacity = 0
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        addSubview(headerView)
        headerView.snp.makeConstraints {
            headerHeight = $0.height.equalTo(58).constraint
            headerTop = $0.top.equalToSuperview().constraint
            $0.leading.trailing.equalToSuperview()
        }

        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.trailing.leading.bottom.equalToSuperview()
            $0.top.equalTo(headerView.snp.bottom)
        }

        addSubview(panIndicatorView)
        panIndicatorView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(35)
            $0.height.equalTo(5)
        }

        headerView.addSubview(filterButton)
        filterButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.width.height.equalTo(44)
            $0.centerY.equalToSuperview().inset(3)
        }

        headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            titleLeft = $0.leading.equalToSuperview().inset(Constants.titleLeftCompactInset).constraint
            $0.centerY.equalToSuperview().inset(3)
        }

        headerView.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(10)
            $0.width.height.equalTo(44)
            $0.centerY.equalToSuperview().inset(3)
        }

        addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.trailing.leading.bottom.equalToSuperview()
            $0.top.equalTo(headerView.snp.bottom)
        }
    }
}

extension TransactionHistoryViewLayout {
    enum Constants {
        static let loadingViewMargin: CGFloat = 4.0
        static let cornerRadius: CGFloat = 12
        static let titleLeftCompactInset: CGFloat = 20
    }
}
