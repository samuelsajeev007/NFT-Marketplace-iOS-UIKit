//
//  HomeViewController.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 14/08/26.
//

import UIKit

/// Root view controller — layout defined in Main.storyboard (HomeViewController scene).
/// Swaps between MarketplaceViewController and WalletViewController as child VCs.
final class HomeViewController: UIViewController {

    // MARK: - Dependencies

    var container: AppContainer = AppContainer()

    // MARK: - IBOutlets

    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var profileCardView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var marketplaceButton: UIButton!
    @IBOutlet weak var walletsButton: UIButton!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var indicatorLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentContainerView: UIView!

    // MARK: - Layers & Effects

    private let profileGradientLayer = CAGradientLayer()
    private let dotPatternLayer = CALayer()
    private let dotMaskLayer = CAGradientLayer()
    private var lastDotSize: CGSize = .zero
    private var selectedTab: HomeTab = .marketplace

    // MARK: - Navigation & Dependencies

    weak var coordinator: AppCoordinator?

    // MARK: - Child VCs

    private lazy var marketplaceVC: MarketplaceViewController = {
        let vc: MarketplaceViewController = coordinator?.makeChild(.marketplace) ?? MarketplaceViewController()
        vc.container = self.container
        vc.coordinator = self.coordinator
        vc.viewModel = self.container.marketplaceViewModel
        return vc
    }()

    private lazy var walletVC: WalletViewController = {
        let vc: WalletViewController = coordinator?.makeChild(.wallet) ?? WalletViewController()
        vc.container = self.container
        vc.coordinator = self.coordinator
        vc.viewModel = self.container.walletViewModel
        return vc
    }()

    private var currentChildVC: UIViewController?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateTabUI(animated: false)
        showTab(.marketplace, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let profileCardView, profileCardView.bounds.width > 0, profileCardView.bounds.height > 0 else { return }
        let bounds = profileCardView.bounds

        profileGradientLayer.frame = bounds
        dotPatternLayer.frame = bounds
        dotMaskLayer.frame = bounds

        if dotPatternLayer.contents == nil || lastDotSize != bounds.size {
            lastDotSize = bounds.size
            dotPatternLayer.contents = makeDotPatternImage(size: bounds.size)?.cgImage
        }
    }

    // MARK: - UI Setup

    private func setupUI() {
        // Logo styling
        if let logoLabel {
            logoLabel.text = "TECHBANK"
            logoLabel.font = UIFont.systemFont(ofSize: 19.9, weight: .black)
            applyLogoGradient()
        }

        // Profile card styling
        if let profileCardView {
            profileCardView.layer.cornerRadius = 10
            profileCardView.clipsToBounds = true

            // LinearGradient (75, 90, 252) -> (156, 66, 254) with 0.28 opacity
            let startColor = UIColor(red: 75/255.0, green: 90/255.0, blue: 252/255.0, alpha: 0.28).cgColor
            let endColor   = UIColor(red: 156/255.0, green: 66/255.0, blue: 254/255.0, alpha: 0.28).cgColor

            profileGradientLayer.colors = [startColor, endColor]
            profileGradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            profileGradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            if profileGradientLayer.superlayer == nil {
                profileCardView.layer.insertSublayer(profileGradientLayer, at: 0)
            }

            // Dot mask: .white to .white.opacity(0.3), topLeading to bottomTrailing
            dotMaskLayer.colors = [
                UIColor.white.cgColor,
                UIColor.white.withAlphaComponent(0.3).cgColor
            ]
            dotMaskLayer.startPoint = CGPoint(x: 0, y: 0)
            dotMaskLayer.endPoint = CGPoint(x: 1, y: 1)
            dotPatternLayer.mask = dotMaskLayer

            if dotPatternLayer.superlayer == nil {
                profileCardView.layer.insertSublayer(dotPatternLayer, above: profileGradientLayer)
            }
        }

        if let nameLabel {
            nameLabel.text = "Jane Cooper"
            nameLabel.font = UIFont(name: "Poppins-Medium", size: 24) ?? UIFont.boldSystemFont(ofSize: 24)
            nameLabel.textColor = .textDark
        }

        // Tab button fonts & indicator
        marketplaceButton?.titleLabel?.font = UIFont(name: "SofiaProSemiBold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .semibold)
        walletsButton?.titleLabel?.font = UIFont(name: "SofiaProMedium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        indicatorView?.layer.cornerRadius = 3
        indicatorView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        indicatorView?.clipsToBounds = true
        indicatorView?.backgroundColor = UIColor(red: 51/255.0, green: 137/255.0, blue: 251/255.0, alpha: 1.0)
    }

    private func applyLogoGradient() {
        let colors = [
            UIColor(red: 74/255.0, green: 90/255.0, blue: 252/255.0, alpha: 1.0).cgColor,
            UIColor(red: 158/255.0, green: 65/255.0, blue: 254/255.0, alpha: 1.0).cgColor
        ]
        let size = CGSize(width: 140, height: 30)
        let renderer = UIGraphicsImageRenderer(size: size)
        let gradientImage = renderer.image { ctx in
            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: nil
            ) else { return }
            ctx.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 15),
                end: CGPoint(x: 140, y: 15),
                options: []
            )
        }
        logoLabel?.textColor = UIColor(patternImage: gradientImage)
    }

    // MARK: - IBActions

    @IBAction func marketplaceButtonTapped(_ sender: UIButton) {
        setTab(.marketplace)
    }

    @IBAction func walletsButtonTapped(_ sender: UIButton) {
        setTab(.myWallets)
    }

    // MARK: - Tab Switching

    private func setTab(_ tab: HomeTab) {
        guard selectedTab != tab else { return }
        selectedTab = tab
        updateTabUI(animated: true)
        showTab(tab, animated: true)

        if tab == .marketplace {
            marketplaceVC.refreshData()
        }
    }

    private func updateTabUI(animated: Bool) {
        let isMarketplace = (selectedTab == .marketplace)
        marketplaceButton?.titleLabel?.font = UIFont(name: isMarketplace ? "SofiaProSemiBold" : "SofiaProMedium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: isMarketplace ? .semibold : .medium)
        walletsButton?.titleLabel?.font = UIFont(name: isMarketplace ? "SofiaProMedium" : "SofiaProSemiBold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: isMarketplace ? .medium : .semibold)

        let inset: CGFloat = 16
        let segmentControlWidth = indicatorView?.superview?.bounds.width ?? view.bounds.width
        let tabWidth = segmentControlWidth > 0 ? segmentControlWidth / 2.0 : (view.bounds.width / 2.0)
        let targetLeading: CGFloat = (isMarketplace ? 0 : tabWidth) + inset
        indicatorLeadingConstraint?.constant = targetLeading

        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: []) {
                self.view.layoutIfNeeded()
            }
        } else {
            view.layoutIfNeeded()
        }
    }

    private func showTab(_ tab: HomeTab, animated: Bool) {
        guard let contentContainerView else { return }
        let targetVC: UIViewController = tab == .marketplace ? marketplaceVC : walletVC

        if let current = currentChildVC {
            if current === targetVC { return }
            addChild(targetVC)
            targetVC.view.frame = contentContainerView.bounds
            targetVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            if animated {
                targetVC.view.alpha = 0
                contentContainerView.addSubview(targetVC.view)
                UIView.animate(withDuration: 0.25) {
                    targetVC.view.alpha = 1
                    current.view.alpha = 0
                } completion: { _ in
                    current.view.removeFromSuperview()
                    current.removeFromParent()
                    targetVC.didMove(toParent: self)
                }
            } else {
                contentContainerView.addSubview(targetVC.view)
                current.view.removeFromSuperview()
                current.removeFromParent()
                targetVC.didMove(toParent: self)
            }
        } else {
            addChild(targetVC)
            targetVC.view.frame = contentContainerView.bounds
            targetVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentContainerView.addSubview(targetVC.view)
            targetVC.didMove(toParent: self)
        }

        currentChildVC = targetVC
    }

    // MARK: - Dot Pattern Helper

    private func makeDotPatternImage(size: CGSize) -> UIImage? {
        guard size.width > 0 && size.height > 0 else { return nil }
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { ctx in
            let step: CGFloat = 8
            let dotSize: CGFloat = 2
            UIColor.white.withAlphaComponent(0.4).setFill()
            for x in stride(from: 0, through: size.width, by: step) {
                for y in stride(from: 0, through: size.height, by: step) {
                    let rect = CGRect(x: x, y: y, width: dotSize, height: dotSize)
                    ctx.cgContext.fill(rect)
                }
            }
        }
    }
}
