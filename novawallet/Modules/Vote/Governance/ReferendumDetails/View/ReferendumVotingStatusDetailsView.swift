import UIKit

final class ReferendumVotingStatusDetailsView: UIView {
    let statusView = ReferendumVotingStatusView()
    let votingProgressView = VotingProgressView()
    let ayeVotesView: VoteRowView = .create {
        $0.apply(style: .init(
            color: R.color.colorRedFF3A69()!,
            accessoryImage: R.image.iconInfo()!
        ))
    }

    let nayVotesView: VoteRowView = .create {
        $0.apply(style: .init(
            color: R.color.colorGreen15CF37()!,
            accessoryImage: R.image.iconInfo()!
        ))
    }

    let voteButton: ButtonLargeControl = .create {
        $0.titleLabel.textAlignment = .center
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
        let content = UIView.vStack(
            spacing: 16,
            [
                statusView,
                votingProgressView,
                UIView.vStack(
                    distribution: .fillEqually,
                    [
                        ayeVotesView,
                        nayVotesView
                    ]
                ),
                voteButton
            ]
        )
        addSubview(content)
        content.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
    }
}

extension ReferendumVotingStatusDetailsView: BindableView {
    struct Model {
        let status: ReferendumVotingStatusView.Model
        let votingProgress: VotingProgressView.Model?
        let aye: VoteRowView.Model?
        let nay: VoteRowView.Model?
        let buttonText: String?
    }

    func bind(viewModel: Model) {
        statusView.bind(viewModel: viewModel.status)
        votingProgressView.bindOrHide(viewModel: viewModel.votingProgress)
        ayeVotesView.bindOrHide(viewModel: viewModel.aye)
        nayVotesView.bindOrHide(viewModel: viewModel.nay)
        if let buttonText = viewModel.buttonText {
            voteButton.isHidden = false
            voteButton.bind(title: buttonText, details: nil)
        } else {
            voteButton.isHidden = true
        }
    }
}
