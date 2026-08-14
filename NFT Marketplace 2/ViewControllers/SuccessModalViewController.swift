//
//  SuccessModalViewController.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 14/08/26.
//

import UIKit

/// Full-screen success modal — layout defined in Main.storyboard.
final class SuccessModalViewController: UIViewController {

    // MARK: - Configuration

    var titleText: String = "Success!"
    var messageText: String = ""
    var buttonTitle: String = "View NFT"
    var showArrow: Bool = true
    var onAction: (() -> Void)?

    // MARK: - IBOutlets

    @IBOutlet weak var sheetView: UIView!
    @IBOutlet weak var successImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!

    // MARK: - Layers

    private let actionButtonGradientLayer = CAGradientLayer()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        actionButtonGradientLayer.frame = actionButton.bounds
        actionButton.layer.cornerRadius = actionButton.bounds.height / 2
    }

    // MARK: - Setup

    private func setupUI() {
        sheetView.layer.cornerRadius = 24
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        successImageView.image = UIImage(named: "successImage") ?? UIImage(systemName: "checkmark.circle.fill")
        titleLabel.text = titleText
        messageLabel.text = messageText

        let btnTitle = showArrow ? "\(buttonTitle)  →" : buttonTitle
        actionButton.setTitle(btnTitle, for: .normal)

        actionButtonGradientLayer.colors = [
            UIColor.buyButtonGradientStart.cgColor,
            UIColor.buyButtonGradientEnd.cgColor
        ]
        actionButtonGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        actionButtonGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        actionButton.layer.insertSublayer(actionButtonGradientLayer, at: 0)
        actionButton.clipsToBounds = true
    }

    // MARK: - IBActions

    @IBAction func actionTapped(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            self?.onAction?()
        }
    }
}
