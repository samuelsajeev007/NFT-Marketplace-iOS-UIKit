//
//  PurchaseConfirmationViewController.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 14/08/26.
//

import UIKit
import Observation

/// Bottom-sheet purchase confirmation — layout defined in Main.storyboard.
final class PurchaseConfirmationViewController: UIViewController {

    // MARK: - Dependencies

    var viewModel: PurchaseViewModel!

    // MARK: - IBOutlets

    @IBOutlet weak var sheetView: UIView!
    @IBOutlet weak var nftThumbImageView: UIImageView!
    @IBOutlet weak var nftTitleLabel: UILabel!
    @IBOutlet weak var buyingPriceValueLabel: UILabel!
    @IBOutlet weak var walletBalanceValueLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var dashedLine1: UIView!
    @IBOutlet weak var dashedLine2: UIView!
    @IBOutlet weak var dashedLine3: UIView!

    // MARK: - Layers

    private let buyButtonGradientLayer = CAGradientLayer()
    private var observationTask: Task<Void, Never>?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        Task { await viewModel.fetchBalance() }
        startObserving()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        buyButtonGradientLayer.frame = buyButton.bounds
        buyButton.layer.cornerRadius = buyButton.bounds.height / 2
    }

    deinit {
        observationTask?.cancel()
    }

    // MARK: - Setup

    private func setupUI() {
        sheetView.layer.cornerRadius = 24
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        nftThumbImageView.layer.cornerRadius = 8
        nftThumbImageView.clipsToBounds = true

        // Typography
        nftTitleLabel.font = UIFont(name: "Poppins-SemiBold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        buyingPriceValueLabel.font = UIFont(name: "Poppins-SemiBold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        walletBalanceValueLabel.font = UIFont(name: "Poppins-SemiBold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        buyButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        errorLabel.font = UIFont(name: "Poppins-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)

        // Buy button gradient
        buyButtonGradientLayer.colors = [
            UIColor.buyButtonGradientStart.cgColor,
            UIColor.buyButtonGradientEnd.cgColor
        ]
        buyButtonGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        buyButtonGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        buyButton.layer.insertSublayer(buyButtonGradientLayer, at: 0)
        buyButton.clipsToBounds = true

        // Configure initial data
        nftThumbImageView.loadImage(from: viewModel.nft.imageUrl)
        nftTitleLabel.text = viewModel.nft.title
        buyingPriceValueLabel.text = "\(String(format: "%.2f", NSDecimalNumber(decimal: viewModel.nft.price).doubleValue)) \(viewModel.nft.currency ?? "USDT")"
    }

    // MARK: - Observation

    private func startObserving() {
        observationTask = Task { @MainActor [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                withObservationTracking {
                    let balance    = self.viewModel.usdtBalance
                    let isLoading  = self.viewModel.isLoading
                    let hasFunds   = self.viewModel.hasSufficientBalance
                    let error      = self.viewModel.errorMessage
                    let didSucceed = self.viewModel.showSuccessModal

                    let balanceStr = "\(String(format: "%.2f", NSDecimalNumber(decimal: balance).doubleValue)) USDT"
                    self.walletBalanceValueLabel.text = balanceStr
                    self.walletBalanceValueLabel.textColor = hasFunds ? .black : .red
                    self.buyButton.isEnabled = hasFunds && !isLoading
                    self.buyButton.alpha = (hasFunds && !isLoading) ? 1.0 : 0.5

                    if isLoading {
                        self.loadingIndicator.startAnimating()
                        self.buyButton.setTitle("", for: .normal)
                    } else {
                        self.loadingIndicator.stopAnimating()
                        self.buyButton.setTitle("Buy NFT  →", for: .normal)
                    }

                    if let error {
                        self.errorLabel.text = error
                        self.errorLabel.isHidden = false
                    } else {
                        self.errorLabel.isHidden = true
                    }

                    if didSucceed {
                        self.showSuccessModal()
                    }
                } onChange: {}
                await Task.yield()
            }
        }
    }

    // MARK: - IBActions

    @IBAction func dimmingTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func buyTapped(_ sender: UIButton) {
        Task { await viewModel.purchase() }
    }

    private func showSuccessModal() {
        let successVC = storyboard!.instantiateViewController(withIdentifier: "SuccessModalViewController") as! SuccessModalViewController
        successVC.titleText = "Purchase Successful!"
        successVC.messageText = "View it anytime in My NFTs."
        successVC.buttonTitle = "Close"
        successVC.showArrow = false
        successVC.onAction = { [weak self] in
            self?.viewModel.dismissModal()
            self?.dismiss(animated: true)
        }
        successVC.modalPresentationStyle = .overFullScreen
        successVC.modalTransitionStyle = .crossDissolve
        present(successVC, animated: true)
    }
}
