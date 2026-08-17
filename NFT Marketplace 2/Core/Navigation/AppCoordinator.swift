//
//  AppCoordinator.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 17/08/26.
//

import UIKit

/// Central application coordinator managing navigation flow and dependency resolution.
final class AppCoordinator: Coordinator {

    var navigationController: UINavigationController
    let container: AppContainer
    private let factory: ViewControllerFactory

    init(
        navigationController: UINavigationController,
        container: AppContainer,
        factory: ViewControllerFactory = ViewControllerFactory()
    ) {
        self.navigationController = navigationController
        self.container = container
        self.factory = factory
    }

    func start() {
        let homeVC: HomeViewController = factory.make(.home)
        homeVC.container = container
        homeVC.coordinator = self
        navigationController.setViewControllers([homeVC], animated: false)
        navigationController.setNavigationBarHidden(true, animated: false)
    }

    func navigate(to route: AppRoute) {
        switch route {
        case .home:
            popToRoot()

        case .nftDetail(let nft):
            let detailVC: NFTDetailViewController = factory.make(.nftDetail)
            detailVC.nft = nft
            detailVC.container = container
            detailVC.coordinator = self
            navigationController.pushViewController(detailVC, animated: true)

        case .purchaseConfirmation(let nft):
            let purchaseVC: PurchaseConfirmationViewController = factory.make(.purchaseConfirmation)
            let viewModel = container.makePurchaseViewModel(for: nft)
            purchaseVC.viewModel = viewModel
            purchaseVC.coordinator = self
            purchaseVC.modalPresentationStyle = .overFullScreen
            purchaseVC.modalTransitionStyle = .crossDissolve
            navigationController.present(purchaseVC, animated: true)

        case .createNFT:
            let createVC: CreateNFTViewController = factory.make(.createNFT)
            createVC.viewModel = container.createNFTViewModel
            createVC.coordinator = self
            navigationController.pushViewController(createVC, animated: true)

        case .successModal(let title, let message, let buttonTitle, let showArrow, let onAction):
            let successVC: SuccessModalViewController = factory.make(.successModal)
            successVC.titleText = title
            successVC.messageText = message
            successVC.buttonTitle = buttonTitle
            successVC.showArrow = showArrow
            successVC.onAction = onAction
            successVC.modalPresentationStyle = .overFullScreen
            successVC.modalTransitionStyle = .crossDissolve

            if let presented = navigationController.presentedViewController {
                presented.present(successVC, animated: true)
            } else {
                navigationController.present(successVC, animated: true)
            }
        }
    }

    func makeChild<T: UIViewController>(_ identifier: StoryboardIdentifier) -> T {
        factory.make(identifier)
    }

    func pop(animated: Bool = true) {
        navigationController.popViewController(animated: animated)
    }

    func popToRoot(animated: Bool = true) {
        navigationController.popToRootViewController(animated: animated)
    }

    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        if let presented = navigationController.presentedViewController {
            presented.dismiss(animated: animated, completion: completion)
        } else {
            navigationController.dismiss(animated: animated, completion: completion)
        }
    }
}
