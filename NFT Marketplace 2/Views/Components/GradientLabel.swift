//
//  GradientLabel.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 14/08/26.
//

import UIKit

/// A UILabel subclass that renders its text with a horizontal linear gradient fill.
/// Used for the "TECHBANK" logo text.
final class GradientLabel: UILabel {

    // MARK: - Properties

    var gradientColors: [CGColor] = [] {
        didSet { setNeedsDisplay() }
    }

    var startPoint: CGPoint = CGPoint(x: 0, y: 0.5) {
        didSet { setNeedsDisplay() }
    }

    var endPoint: CGPoint = CGPoint(x: 1, y: 0.5) {
        didSet { setNeedsDisplay() }
    }

    // MARK: - Drawing

    override func drawText(in rect: CGRect) {
        guard !gradientColors.isEmpty,
              let gradientImage = makeGradientImage(in: rect) else {
            super.drawText(in: rect)
            return
        }
        textColor = UIColor(patternImage: gradientImage)
        super.drawText(in: rect)
    }

    private func makeGradientImage(in rect: CGRect) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { ctx in
            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: gradientColors as CFArray,
                locations: nil
            ) else { return }
            let start = CGPoint(x: rect.width * startPoint.x, y: rect.height * startPoint.y)
            let end   = CGPoint(x: rect.width * endPoint.x,   y: rect.height * endPoint.y)
            ctx.cgContext.drawLinearGradient(gradient, start: start, end: end, options: [])
        }
    }
}
