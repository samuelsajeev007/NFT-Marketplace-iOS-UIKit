//
//  UIImageView+AsyncLoad.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 14/08/26.
//

import UIKit

// MARK: - Cancellable token

private var imageTaskKey: UInt8 = 0

extension UIImageView {

    // MARK: - Async Image Loading

    /// Loads an image from a remote URL asynchronously.
    /// Shows a spinner while loading and a placeholder SF symbol on failure.
    func loadImage(from url: URL?, placeholder: UIImage? = nil) {
        // Cancel any previous task
        cancelImageLoad()

        // Show placeholder immediately
        image = placeholder ?? UIImage(systemName: "photo")
        tintColor = .systemGray3

        guard let url = url else { return }

        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        let task = Task { [weak self] in
            guard let self else { return }
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard !Task.isCancelled else { return }
                if let loaded = UIImage(data: data) {
                    await MainActor.run {
                        spinner.removeFromSuperview()
                        UIView.transition(with: self, duration: 0.25, options: .transitionCrossDissolve) {
                            self.image = loaded
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    spinner.removeFromSuperview()
                    self.image = UIImage(systemName: "photo")
                    self.tintColor = .systemGray3
                }
            }
        }

        // Store the task so it can be cancelled
        objc_setAssociatedObject(self, &imageTaskKey, task, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    func cancelImageLoad() {
        (objc_getAssociatedObject(self, &imageTaskKey) as? Task<Void, Never>)?.cancel()
    }
}
