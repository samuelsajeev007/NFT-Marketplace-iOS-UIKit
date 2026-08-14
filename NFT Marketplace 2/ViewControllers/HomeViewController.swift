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
    private var selectedTab: HomeTab = .marketplace

    // MARK: - Child VCs

    private lazy var marketplaceVC: MarketplaceViewController = {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MarketplaceViewController") as? MarketplaceViewController ?? MarketplaceViewController()
        vc.container = self.container
        vc.viewModel = self.container.marketplaceViewModel
        return vc
    }()

    private lazy var walletVC: WalletViewController = {
        let vc = storyboard?.instantiateViewController(withIdentifier: "WalletViewController") as? WalletViewController ?? WalletViewController()
        vc.container = self.container
        vc.viewModel = self.container.walletViewModel
        return vc
    }()

    private var currentChildVC: UIViewController?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        showTab(.marketplace, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let profileCardView {
            profileGradientLayer.frame = profileCardView.bounds

            if dotPatternLayer.superlayer == nil && profileCardView.bounds.width > 0 {
                let dotImage = makeDotPatternImage(size: profileCardView.bounds.size)
                dotPatternLayer.contents = dotImage?.cgImage
                dotPatternLayer.frame = profileCardView.bounds
                dotPatternLayer.opacity = 0.4
                profileCardView.layer.insertSublayer(dotPatternLayer, above: profileGradientLayer)
            }
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

            profileGradientLayer.colors = [
                UIColor.profileCardGradientStart.withAlphaComponent(0.28).cgColor,
                UIColor.profileCardGradientEnd.withAlphaComponent(0.28).cgColor
            ]
            profileGradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            profileGradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            profileCardView.layer.insertSublayer(profileGradientLayer, at: 0)
        }

        if let nameLabel {
            nameLabel.text = "Jane Cooper"
            nameLabel.font = UIFont(name: "Poppins-Medium", size: 24) ?? UIFont.boldSystemFont(ofSize: 24)
            nameLabel.textColor = .textDark
        }

        // Tab button fonts & indicator
        marketplaceButton?.titleLabel?.font = UIFont(name: "SofiaProSemiBold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .semibold)
        walletsButton?.titleLabel?.font = UIFont(name: "SofiaProMedium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        indicatorView?.backgroundColor = .techbankBlue
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
    }

    private func updateTabUI(animated: Bool) {
        let isMarketplace = (selectedTab == .marketplace)
        marketplaceButton?.titleLabel?.font = UIFont(name: isMarketplace ? "SofiaProSemiBold" : "SofiaProMedium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: isMarketplace ? .semibold : .medium)
        walletsButton?.titleLabel?.font = UIFont(name: isMarketplace ? "SofiaProMedium" : "SofiaProSemiBold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: isMarketplace ? .medium : .semibold)

        let targetLeading: CGFloat = isMarketplace ? 0 : (view.bounds.width / 2.0)
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
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            let step: CGFloat = 8
            let dotSize: CGFloat = 2
            UIColor.white.withAlphaComponent(0.4).setFill()
            var x: CGFloat = 0
            while x <= size.width {
                var y: CGFloat = 0
                while y <= size.height {
                    let rect = CGRect(x: x, y: y, width: dotSize, height: dotSize)
                    UIBezierPath(rect: rect).fill()
                    y += step
                }
                x += step
            }
        }
    }
}
