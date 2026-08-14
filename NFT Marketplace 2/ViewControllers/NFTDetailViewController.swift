//
//  NFTDetailViewController.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 14/08/26.
//

import UIKit

/// Full-screen NFT detail view — layout defined in Main.storyboard.
final class NFTDetailViewController: UIViewController {

    // MARK: - Dependencies

    var nft: NFT!
    var container: AppContainer = AppContainer()

    // MARK: - IBOutlets

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var priceTitleLabel: UILabel!
    @IBOutlet weak var priceValueLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!

    // MARK: - Layers

    private let buyButtonGradientLayer = CAGradientLayer()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
        configure()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let buyButton {
            buyButtonGradientLayer.frame = buyButton.bounds
            buyButton.layer.cornerRadius = buyButton.bounds.height / 2
        }
    }

    // MARK: - Setup

    private func setupUI() {
        // Main Image styling
        heroImageView?.layer.cornerRadius = 16
        heroImageView?.clipsToBounds = true

        // Fonts & Colors
        titleLabel?.font = UIFont(name: "Poppins-Medium", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .medium)
        titleLabel?.textColor = UIColor(red: 23/255.0, green: 24/255.0, blue: 22/255.0, alpha: 1.0)

        creatorNameLabel?.font = UIFont(name: "Poppins-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        creatorNameLabel?.textColor = UIColor(red: 151/255.0, green: 151/255.0, blue: 150/255.0, alpha: 1.0)

        descriptionLabel?.font = UIFont(name: "Poppins-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        descriptionLabel?.textColor = UIColor(red: 151/255.0, green: 151/255.0, blue: 150/255.0, alpha: 1.0)

        priceTitleLabel?.font = UIFont(name: "Poppins-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        priceTitleLabel?.textColor = UIColor(red: 151/255.0, green: 151/255.0, blue: 150/255.0, alpha: 1.0)

        priceValueLabel?.font = UIFont(name: "SpaceGrotesk-Regular", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .bold)
        priceValueLabel?.textColor = UIColor(red: 23/255.0, green: 24/255.0, blue: 22/255.0, alpha: 1.0)

        // Bottom bar shadow
        if let bottomBar {
            bottomBar.layer.shadowColor = UIColor(red: 151/255.0, green: 151/255.0, blue: 150/255.0, alpha: 0.14).cgColor
            bottomBar.layer.shadowOffset = CGSize(width: 0, height: -5)
            bottomBar.layer.shadowRadius = 30
            bottomBar.layer.shadowOpacity = 1
        }

        // Buy button styling
        if let buyButton {
            buyButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .semibold)
            buyButtonGradientLayer.colors = [
                UIColor(red: 58/255.0, green: 108/255.0, blue: 244/255.0, alpha: 1.0).cgColor,
                UIColor(red: 14/255.0, green: 195/255.0, blue: 244/255.0, alpha: 1.0).cgColor
            ]
            buyButtonGradientLayer.startPoint = CGPoint(x: 0, y: 0)
            buyButtonGradientLayer.endPoint = CGPoint(x: 1, y: 1)
            buyButton.layer.insertSublayer(buyButtonGradientLayer, at: 0)
            buyButton.clipsToBounds = true
        }

        // Nav Buttons
        if let backButton {
            backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)), for: .normal)
            backButton.tintColor = .black
            backButton.backgroundColor = UIColor(red: 246/255.0, green: 251/255.0, blue: 231/255.0, alpha: 0.35)
            backButton.layer.cornerRadius = 22
            backButton.clipsToBounds = true
        }

        if let shareButton {
            let shareImg = UIImage(named: "shareIcon") ?? UIImage(systemName: "square.and.arrow.up")
            shareButton.setImage(shareImg, for: .normal)
            shareButton.tintColor = .black
        }
    }

    private func configure() {
        guard let nft else { return }
        heroImageView?.loadImage(from: nft.imageUrl)
        titleLabel?.text = nft.title
        descriptionLabel?.text = nft.description ?? "No description available."
        priceValueLabel?.text = nft.price.formattedAsUSDT
        creatorNameLabel?.text = (nft.createdBy == "691461156dc97f9ce2987297" ? "Theresa Webb" : nft.createdBy)
    }

    // MARK: - IBActions

    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func buyButtonTapped(_ sender: UIButton) {
        guard let nft else { return }
        let purchaseVM = container.makePurchaseViewModel(for: nft)
        let purchaseVC = storyboard?.instantiateViewController(withIdentifier: "PurchaseConfirmationViewController") as? PurchaseConfirmationViewController ?? PurchaseConfirmationViewController()
        purchaseVC.viewModel = purchaseVM
        purchaseVC.modalPresentationStyle = .overFullScreen
        purchaseVC.modalTransitionStyle = .coverVertical
        present(purchaseVC, animated: true)
    }

    @IBAction func shareTapped(_ sender: UIButton) {
        guard let nft else { return }
        let shareText = "Check out this awesome NFT: \(nft.title) for \(nft.price.formattedAsUSDT)!"
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        if let popover = activityVC.popoverPresentationController, let shareButton {
            popover.sourceView = shareButton
            popover.sourceRect = shareButton.bounds
        }
        present(activityVC, animated: true)
    }
}
