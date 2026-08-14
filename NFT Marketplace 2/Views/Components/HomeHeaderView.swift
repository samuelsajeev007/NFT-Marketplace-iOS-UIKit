//
//  HomeHeaderView.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 14/08/26.
//

import UIKit

/// The top bar showing the "TECHBANK" gradient logo — mirrors SwiftUI HomeHeaderView.
final class HomeHeaderView: UIView {

    // MARK: - Subviews

    private let logoLabel = GradientLabel()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .white
        addSubview(logoLabel)
        logoLabel.translatesAutoresizingMaskIntoConstraints = false

        logoLabel.text = "TECHBANK"
        logoLabel.font = UIFont.systemFont(ofSize: 19.9, weight: .black)
        logoLabel.gradientColors = [
            UIColor(red: 74/255, green: 90/255,  blue: 252/255, alpha: 1).cgColor,
            UIColor(red: 158/255, green: 65/255, blue: 254/255, alpha: 1).cgColor
        ]
        logoLabel.startPoint = CGPoint(x: 0, y: 0.5)
        logoLabel.endPoint   = CGPoint(x: 1, y: 0.5)

        NSLayoutConstraint.activate([
            logoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            logoLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            logoLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            logoLabel.widthAnchor.constraint(equalToConstant: 130)
        ])
    }
}
