import UIKit
import SubstrateSdk
import RobinHood
import SoraKeystore

final class AddDelegationInteractor {
    weak var presenter: AddDelegationInteractorOutputProtocol?

    let chain: ChainModel
    let lastVotedDays: Int
    let delegateListOperationFactory: GovernanceDelegateListFactoryProtocol
    let connection: JSONRPCEngine
    let runtimeService: RuntimeCodingServiceProtocol
    let generalLocalSubscriptionFactory: GeneralStorageSubscriptionFactoryProtocol
    private(set) var settings: SettingsManagerProtocol
    let blockTimeService: BlockTimeEstimationServiceProtocol
    let blockTimeFactory: BlockTimeOperationFactoryProtocol
    let operationQueue: OperationQueue

    private var blockNumberSubscription: AnyDataProvider<DecodedBlockNumber>?
    private var currentBlockNumber: BlockNumber?

    init(
        chain: ChainModel,
        lastVotedDays: Int,
        connection: JSONRPCEngine,
        runtimeService: RuntimeCodingServiceProtocol,
        generalLocalSubscriptionFactory: GeneralStorageSubscriptionFactoryProtocol,
        delegateListOperationFactory: GovernanceDelegateListFactoryProtocol,
        blockTimeService: BlockTimeEstimationServiceProtocol,
        blockTimeFactory: BlockTimeOperationFactoryProtocol,
        settings: SettingsManagerProtocol,
        operationQueue: OperationQueue
    ) {
        self.chain = chain
        self.lastVotedDays = lastVotedDays
        self.connection = connection
        self.runtimeService = runtimeService
        self.generalLocalSubscriptionFactory = generalLocalSubscriptionFactory
        self.delegateListOperationFactory = delegateListOperationFactory
        self.blockTimeService = blockTimeService
        self.blockTimeFactory = blockTimeFactory
        self.settings = settings
        self.operationQueue = operationQueue
    }

    private func fetchBlockTimeAndUpdateDelegates() {
        let blockTimeUpdateWrapper = blockTimeFactory.createBlockTimeOperation(
            from: runtimeService,
            blockTimeEstimationService: blockTimeService
        )

        blockTimeUpdateWrapper.targetOperation.completionBlock = { [weak self] in
            DispatchQueue.main.async {
                do {
                    let blockTime = try blockTimeUpdateWrapper.targetOperation.extractNoCancellableResultData()

                    self?.fetchDelegateList(for: blockTime)
                } catch {
                    self?.presenter?.didReceiveError(.blockTimeFetchFailed(error))
                }
            }
        }

        operationQueue.addOperations(blockTimeUpdateWrapper.allOperations, waitUntilFinished: false)
    }

    private func fetchDelegateList(for blockTime: BlockTime) {
        guard
            let activityBlockNumber = currentBlockNumber?.blockBackInDays(
                lastVotedDays,
                blockTime: blockTime
            ) else {
            return
        }

        let wrapper = delegateListOperationFactory.fetchDelegateListWrapper(
            for: activityBlockNumber,
            chain: chain,
            connection: connection,
            runtimeService: runtimeService
        )

        wrapper.targetOperation.completionBlock = { [weak self] in
            DispatchQueue.main.async {
                do {
                    let delegates = try wrapper.targetOperation.extractNoCancellableResultData()
                    self?.presenter?.didReceiveDelegates(delegates)
                } catch {
                    self?.presenter?.didReceiveError(.delegateListFetchFailed(error))
                }
            }
        }

        operationQueue.addOperations(wrapper.allOperations, waitUntilFinished: false)
    }

    private func subscribeBlockNumber() {
        blockNumberSubscription = subscribeToBlockNumber(for: chain.chainId)
    }

    private func provideSettings() {
        presenter?.didReceiveShouldDisplayBanner(settings.governanceDelegateInfoSeen)
    }
}

extension AddDelegationInteractor: AddDelegationInteractorInputProtocol {
    func setup() {
        subscribeBlockNumber()
        provideSettings()
    }

    func remakeSubscriptions() {
        subscribeBlockNumber()
    }

    func refreshDelegates() {
        if currentBlockNumber != nil {
            fetchBlockTimeAndUpdateDelegates()
        }
    }

    func saveCloseBanner() {
        settings.governanceDelegateInfoSeen = true
    }
}

extension AddDelegationInteractor: GeneralLocalStorageSubscriber, GeneralLocalStorageHandler {
    func handleBlockNumber(result: Result<BlockNumber?, Error>, chainId _: ChainModel.Id) {
        switch result {
        case let .success(blockNumber):
            guard let blockNumber = blockNumber else {
                return
            }

            let optLastBlockNumber = currentBlockNumber
            currentBlockNumber = blockNumber

            if let lastBlockNumber = optLastBlockNumber, blockNumber.isNext(to: lastBlockNumber) {
                return
            }

            fetchBlockTimeAndUpdateDelegates()
        case let .failure(error):
            presenter?.didReceiveError(.blockSubscriptionFailed(error))
        }
    }
}