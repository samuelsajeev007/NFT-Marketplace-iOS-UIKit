//
//  SceneDelegate.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 14/08/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    /// Shared dependency container — lives for the lifetime of the scene.
    let container = AppContainer()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let navController = storyboard.instantiateInitialViewController() as? UINavigationController,
              let homeVC = navController.topViewController as? HomeViewController else {
            return
        }

        homeVC.container = container
        navController.setNavigationBarHidden(true, animated: false)

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navController
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
