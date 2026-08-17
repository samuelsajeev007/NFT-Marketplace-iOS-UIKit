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
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var nftThumbImageView: UIImageView!
    @IBOutlet weak var nftTitleLabel: UILabel!
    @IBOutlet weak var creatorNameLabel: UILabel!
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
    private var hasHandledSuccess: Bool = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        Task { await viewModel.fetchBalance() }
        startObserving()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let buyButton {
            let radius = buyButton.bounds.height / 2
            buyButtonGradientLayer.frame = buyButton.bounds
            buyButtonGradientLayer.cornerRadius = radius
            buyButton.layer.cornerRadius = radius
            buyButton.clipsToBounds = true
        }

        // Draw dashed lines
        if let dashedLine1 { drawDashedLine(on: dashedLine1) }
        if let dashedLine2 { drawDashedLine(on: dashedLine2) }
        if let dashedLine3 { drawDashedLine(on: dashedLine3) }
    }

    deinit {
        observationTask?.cancel()
    }

    // MARK: - Setup

    private func setupUI() {
        if let sheetView {
            sheetView.layer.cornerRadius = 24
            sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            sheetView.clipsToBounds = true
        }

        if let nftThumbImageView {
            nftThumbImageView.layer.cornerRadius = 8
            nftThumbImageView.clipsToBounds = true
        }

        // Header
        headerTitleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        headerTitleLabel?.textColor = .black

        if let closeButton {
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
            closeButton.setImage(UIImage(systemName: "xmark", withConfiguration: symbolConfig), for: .normal)
            closeButton.tintColor = .black
        }

        // Typography
        nftTitleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        nftTitleLabel?.textColor = .black

        creatorNameLabel?.font = UIFont(name: "Poppins-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        creatorNameLabel?.textColor = UIColor(red: 151/255.0, green: 151/255.0, blue: 150/255.0, alpha: 1.0)

        buyingPriceValueLabel?.font = UIFont(name: "Poppins-Regular", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        buyingPriceValueLabel?.textColor = .black

        walletBalanceValueLabel?.font = UIFont(name: "Poppins-Regular", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)

        errorLabel?.font = UIFont(name: "Poppins-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)

        // Buy button styling
        if let buyButton {
            var config = UIButton.Configuration.plain()
            config.cornerStyle = .capsule
            config.baseForegroundColor = .white
            config.baseBackgroundColor = .clear
            let arrowImg = UIImage(named: "sideArrow") ?? UIImage(systemName: "arrow.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold))
            config.image = arrowImg?.withRenderingMode(.alwaysTemplate)
            config.imagePlacement = .trailing
            config.imagePadding = 10
            var titleAttr = AttributedString("Buy NFT")
            titleAttr.font = UIFont(name: "Poppins-SemiBold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .semibold)
            titleAttr.foregroundColor = .white
            config.attributedTitle = titleAttr
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            buyButton.configuration = config

            buyButtonGradientLayer.colors = [
                UIColor(red: 58/255.0, green: 108/255.0, blue: 244/255.0, alpha: 1.0).cgColor,
                UIColor(red: 14/255.0, green: 195/255.0, blue: 244/255.0, alpha: 1.0).cgColor
            ]
            buyButtonGradientLayer.startPoint = CGPoint(x: 0, y: 0)
            buyButtonGradientLayer.endPoint = CGPoint(x: 1, y: 1)
            if buyButtonGradientLayer.superlayer == nil {
                buyButton.layer.insertSublayer(buyButtonGradientLayer, at: 0)
            }
            buyButton.clipsToBounds = true
        }

        // Configure initial data
        if let viewModel {
            nftThumbImageView?.loadImage(from: viewModel.nft.imageUrl)
            nftTitleLabel?.text = viewModel.nft.title
            creatorNameLabel?.text = (viewModel.nft.createdBy == "691461156dc97f9ce2987297" ? "Theresa Webb" : viewModel.nft.createdBy)
            buyingPriceValueLabel?.text = "\(String(format: "%.2f", NSDecimalNumber(decimal: viewModel.nft.price).doubleValue)) \(viewModel.nft.currency ?? "USDT")"
        }
    }

    // MARK: - Dashed Line Drawing

    private func drawDashedLine(on targetView: UIView) {
        guard targetView.bounds.width > 0 else { return }
        targetView.backgroundColor = .clear
        targetView.layer.sublayers?.removeAll(where: { $0 is CAShapeLayer })

        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor(red: 151/255.0, green: 151/255.0, blue: 150/255.0, alpha: 0.35).cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [5, 5]

        let path = CGMutablePath()
        path.addLines(between: [
            CGPoint(x: 0, y: 0.5),
            CGPoint(x: targetView.bounds.width, y: 0.5)
        ])
        shapeLayer.path = path
        targetView.layer.addSublayer(shapeLayer)
    }

    // MARK: - Observation

    private func startObserving() {
        guard let viewModel else { return }
        observationTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                guard let self, let viewModel = self.viewModel else { return }
                await withCheckedContinuation { continuation in
                    var hasResumed = false
                    withObservationTracking {
                        let balance    = viewModel.usdtBalance
                        let isLoading  = viewModel.isLoading
                        let hasFunds   = viewModel.hasSufficientBalance
                        let error      = viewModel.errorMessage
                        let didSucceed = viewModel.showSuccessModal

                        let balanceStr = "\(String(format: "%.2f", NSDecimalNumber(decimal: balance).doubleValue)) USDT"
                        self.walletBalanceValueLabel?.text = balanceStr
                        self.walletBalanceValueLabel?.textColor = hasFunds ? .black : .red
                        self.buyButton?.isEnabled = hasFunds && !isLoading
                        self.buyButton?.alpha = (hasFunds && !isLoading) ? 1.0 : 0.5

                        if isLoading {
                            self.loadingIndicator?.startAnimating()
                            var config = self.buyButton?.configuration
                            config?.attributedTitle = nil
                            config?.image = nil
                            self.buyButton?.configuration = config
                        } else {
                            self.loadingIndicator?.stopAnimating()
                            var config = self.buyButton?.configuration
                            var titleAttr = AttributedString("Buy NFT")
                            titleAttr.font = UIFont(name: "Poppins-SemiBold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .semibold)
                            titleAttr.foregroundColor = .white
                            config?.attributedTitle = titleAttr
                            let arrowImg = UIImage(named: "sideArrow") ?? UIImage(systemName: "arrow.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold))
                            config?.image = arrowImg?.withRenderingMode(.alwaysTemplate)
                            self.buyButton?.configuration = config
                        }

                        if let error {
                            self.errorLabel?.text = error
                            self.errorLabel?.isHidden = false
                        } else {
                            self.errorLabel?.isHidden = true
                        }

                        if didSucceed && !self.hasHandledSuccess {
                            self.hasHandledSuccess = true
                            self.showSuccessModal()
                        }
                    } onChange: {
                        Task { @MainActor in
                            if !hasResumed {
                                hasResumed = true
                                continuation.resume()
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - IBActions

    @IBAction func dimmingTapped(_ sender: UIButton) {
        if let viewModel, !viewModel.isLoading {
            dismiss(animated: true)
        }
    }

    @IBAction func closeTapped(_ sender: UIButton) {
        if let viewModel, !viewModel.isLoading {
            dismiss(animated: true)
        }
    }

    @IBAction func buyTapped(_ sender: UIButton) {
        Task { await viewModel?.purchase() }
    }

    private func showSuccessModal() {
        guard let presentingVC = self.presentingViewController else { return }
        self.dismiss(animated: false) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let successVC = storyboard.instantiateViewController(withIdentifier: "SuccessModalViewController") as? SuccessModalViewController else { return }
            successVC.titleText = "Purchase Successful!"
            successVC.messageText = "View it anytime in My NFTs."
            successVC.buttonTitle = "Close"
            successVC.showArrow = false
            successVC.onAction = {
                successVC.dismiss(animated: true)
            }
            successVC.modalPresentationStyle = .overFullScreen
            successVC.modalTransitionStyle = .crossDissolve
            presentingVC.present(successVC, animated: true)
        }
    }
}
