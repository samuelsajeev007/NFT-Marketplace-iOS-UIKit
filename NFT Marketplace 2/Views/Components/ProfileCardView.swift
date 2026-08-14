//
//  ProfileCardView.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 14/08/26.
//

import UIKit

/// Gradient profile card with dot-pattern overlay and user name label.
/// Mirrors SwiftUI ProfileCardView exactly.
final class ProfileCardView: UIView {

    // MARK: - Subviews

    private let gradientLayer  = CAGradientLayer()
    private let dotPatternLayer = CALayer()
    private let avatarContainer = UIView()
    private let avatarImageView = UIImageView()
    private let nameLabel       = UILabel()

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
        layer.cornerRadius = 10
        clipsToBounds = true

        // Gradient background
        gradientLayer.colors = [
            UIColor(red: 75/255, green: 90/255,  blue: 252/255, alpha: 0.28).cgColor,
            UIColor(red: 156/255, green: 66/255, blue: 254/255, alpha: 0.28).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint   = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(gradientLayer)

        // Avatar circle
        avatarContainer.backgroundColor = .white
        avatarContainer.layer.cornerRadius = 14
        avatarContainer.clipsToBounds = true
        addSubview(avatarContainer)
        avatarContainer.translatesAutoresizingMaskIntoConstraints = false

        avatarImageView.image = UIImage(systemName: "person")
        avatarImageView.tintColor = .black
        avatarImageView.contentMode = .scaleAspectFit
        avatarContainer.addSubview(avatarImageView)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false

        // Name label
        nameLabel.font = UIFont(name: "Poppins-Medium", size: 24) ?? UIFont.boldSystemFont(ofSize: 24)
        nameLabel.textColor = UIColor(red: 17/255, green: 20/255, blue: 28/255, alpha: 1)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            avatarContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            avatarContainer.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            avatarContainer.widthAnchor.constraint(equalToConstant: 28),
            avatarContainer.heightAnchor.constraint(equalToConstant: 28),

            avatarImageView.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 20),
            avatarImageView.heightAnchor.constraint(equalToConstant: 20),

            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            nameLabel.topAnchor.constraint(equalTo: avatarContainer.bottomAnchor, constant: 8),
            nameLabel.widthAnchor.constraint(equalToConstant: 200)
        ])
    }

    // MARK: - Configure

    func configure(userName: String) {
        nameLabel.text = userName
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds

        // Draw dot pattern
        if dotPatternLayer.superlayer == nil {
            let dotImage = makeDotPatternImage(size: bounds.size)
            dotPatternLayer.contents = dotImage?.cgImage
            dotPatternLayer.frame = bounds
            dotPatternLayer.opacity = 0.4
            layer.addSublayer(dotPatternLayer)
        }
    }

    // MARK: - Dot Pattern

    private func makeDotPatternImage(size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
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
