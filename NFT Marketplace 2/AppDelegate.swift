//
//  AppDelegate.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 14/08/26.
//

import UIKit
import CoreText

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        registerCustomFonts()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {}

    // MARK: - Font Registration

    private func registerCustomFonts() {
        let fontExtensions = ["ttf", "otf"]
        var allURLs: [URL] = []

        for ext in fontExtensions {
            if let urls = Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: nil) {
                allURLs.append(contentsOf: urls)
            }
            if let urls = Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: "Fonts") {
                allURLs.append(contentsOf: urls)
            }
        }

        let uniqueURLs = Array(Set(allURLs))
        for url in uniqueURLs {
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                // If font is already registered, this is expected
                if let err = error?.takeUnretainedValue() {
                    let desc = CFErrorCopyDescription(err) as String? ?? "Unknown error"
                    print("Font registration notice for \(url.lastPathComponent): \(desc)")
                }
            }
        }
    }
}
