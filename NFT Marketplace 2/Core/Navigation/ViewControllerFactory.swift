//
//  ViewControllerFactory.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 17/08/26.
//

import UIKit

/// Enumeration of all Storyboard Identifiers to eliminate magic strings.
enum StoryboardIdentifier: String {
    case home = "HomeViewController"
    case marketplace = "MarketplaceViewController"
    case wallet = "WalletViewController"
    case myNFTs = "MyNFTsViewController"
    case coins = "CoinsViewController"
    case nftDetail = "NFTDetailViewController"
    case purchaseConfirmation = "PurchaseConfirmationViewController"
    case createNFT = "CreateNFTViewController"
    case successModal = "SuccessModalViewController"
}

/// Factory that instantiates ViewControllers in a type-safe manner.
final class ViewControllerFactory {

    private let storyboard: UIStoryboard

    init(storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)) {
        self.storyboard = storyboard
    }

    func make<T: UIViewController>(_ identifier: StoryboardIdentifier) -> T {
        guard let vc = storyboard.instantiateViewController(withIdentifier: identifier.rawValue) as? T else {
            fatalError("Could not instantiate view controller with identifier: \(identifier.rawValue) as \(T.self)")
        }
        return vc
    }
}
