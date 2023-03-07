import BigInt

protocol StakingRebagConfirmViewProtocol: ControllerBackedProtocol {
    func didReceiveWallet(viewModel: DisplayWalletViewModel)
    func didReceiveAccount(viewModel: DisplayAddressViewModel)
    func didReceiveNetworkFee(viewModel: BalanceViewModelProtocol?)
    func didReceiveRebags(current: String, next: String)
    func didReceiveHints(viewModel: [String])
    func didStartLoading()
    func didStopLoading()
}

protocol StakingRebagConfirmPresenterProtocol: AnyObject {
    func setup()
    func confirm()
    func selectAccount()
}

protocol StakingRebagConfirmInteractorInputProtocol: AnyObject {
    func setup()
}

protocol StakingRebagConfirmInteractorOutputProtocol: AnyObject {
    func didReceive(price: PriceData?)
    func didReceive(assetBalance: AssetBalance?)
    func didReceive(fee: BigUInt?)
    func didReceive(currentBag: (lowerBound: BigUInt, upperBound: BigUInt))
    func didReceive(error: StakingRebagConfirmError)
}

protocol StakingRebagConfirmWireframeProtocol: AlertPresentable, ErrorPresentable,
    AddressOptionsPresentable {}
