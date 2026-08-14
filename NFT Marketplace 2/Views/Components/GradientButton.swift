//
//  GradientButton.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 14/08/26.
//

import UIKit

/// A UIButton subclass with a CAGradientLayer background.
/// Matches the blue gradient "Buy NFT" / "Create NFT" buttons from SwiftUI.
final class GradientButton: UIButton {

    // MARK: - Gradient Layer

    private let gradientLayer = CAGradientLayer()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        gradientLayer.colors = [
            UIColor.buyButtonGradientStart.cgColor,
            UIColor.buyButtonGradientEnd.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)
        clipsToBounds = true

        setTitleColor(.white, for: .normal)
        setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .disabled)
        titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        layer.cornerRadius = bounds.height / 2   // Capsule shape
    }
}
