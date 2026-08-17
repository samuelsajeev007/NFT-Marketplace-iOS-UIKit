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
        let radius = actionButton.bounds.height / 2
        actionButtonGradientLayer.frame = actionButton.bounds
        actionButtonGradientLayer.cornerRadius = radius
        actionButton.layer.cornerRadius = radius
        actionButton.clipsToBounds = true
    }

    // MARK: - Setup

    private func setupUI() {
        sheetView.layer.cornerRadius = 24
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.clipsToBounds = true

        successImageView.image = UIImage(named: "successImage") ?? UIImage(systemName: "checkmark.circle.fill")

        // Main heading: Poppins-Medium 20px, line-height 150%, centered
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.lineSpacing = 4
        titleParagraphStyle.alignment = .center
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Poppins-Medium", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .medium),
            .foregroundColor: UIColor(red: 23/255.0, green: 24/255.0, blue: 22/255.0, alpha: 1.0),
            .paragraphStyle: titleParagraphStyle
        ]
        titleLabel.attributedText = NSAttributedString(string: titleText, attributes: titleAttributes)

        // Sub heading: Poppins-Regular 14px, line-height 150%, text-align: center, color: #979796
        let subParagraphStyle = NSMutableParagraphStyle()
        subParagraphStyle.lineSpacing = 3
        subParagraphStyle.alignment = .center
        let subAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Poppins-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor(red: 151/255.0, green: 151/255.0, blue: 150/255.0, alpha: 1.0),
            .paragraphStyle: subParagraphStyle
        ]
        messageLabel.attributedText = NSAttributedString(string: messageText, attributes: subAttributes)

        // Action Button
        var config = UIButton.Configuration.plain()
        config.cornerStyle = .capsule
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .clear
        if showArrow {
            let arrowImg = UIImage(named: "sideArrow") ?? UIImage(systemName: "arrow.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold))
            config.image = arrowImg?.withRenderingMode(.alwaysTemplate)
            config.imagePlacement = .trailing
            config.imagePadding = 10
        }
        var titleAttr = AttributedString(buttonTitle)
        titleAttr.font = UIFont(name: "Poppins-SemiBold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleAttr.foregroundColor = .white
        config.attributedTitle = titleAttr
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24)
        actionButton.configuration = config

        actionButtonGradientLayer.colors = [
            UIColor(red: 58/255.0, green: 108/255.0, blue: 244/255.0, alpha: 1.0).cgColor,
            UIColor(red: 14/255.0, green: 195/255.0, blue: 244/255.0, alpha: 1.0).cgColor
        ]
        actionButtonGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        actionButtonGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        if actionButtonGradientLayer.superlayer == nil {
            actionButton.layer.insertSublayer(actionButtonGradientLayer, at: 0)
        }
        actionButton.clipsToBounds = true
    }

    // MARK: - IBActions

    @IBAction func actionTapped(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            self?.onAction?()
        }
    }
}
