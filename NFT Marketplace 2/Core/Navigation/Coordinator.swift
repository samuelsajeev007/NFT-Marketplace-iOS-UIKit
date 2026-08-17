//
//  Coordinator.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 17/08/26.
//

import UIKit

/// Protocol defining navigation capabilities for coordinators.
protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    func start()
    func navigate(to route: AppRoute)
    func pop(animated: Bool)
    func popToRoot(animated: Bool)
    func dismiss(animated: Bool, completion: (() -> Void)?)
}

extension Coordinator {
    func pop(animated: Bool = true) {
        pop(animated: animated)
    }

    func popToRoot(animated: Bool = true) {
        popToRoot(animated: animated)
    }

    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        dismiss(animated: animated, completion: completion)
    }
}
