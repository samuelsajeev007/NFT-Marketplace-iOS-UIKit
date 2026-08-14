//
//  CreateNFTViewModel.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 12/08/26.
//

import Foundation
import Observation
import UIKit

@MainActor
@Observable
final class CreateNFTViewModel {

    // MARK: - Form State

    var title: String = ""
    var nftDescription: String = ""
    var sellingPrice: String = ""
    var selectedImageData: Data?
    var selectedImage: UIImage?

    // MARK: - UI State

    private(set) var isLoading: Bool = false
    private(set) var showSuccessModal: Bool = false
    private(set) var errorMessage: String?

    var isFormValid: Bool {
        !title.isEmpty && !nftDescription.isEmpty && !sellingPrice.isEmpty && selectedImageData != nil
    }

    // MARK: - Dependencies

    private let walletRepository: WalletRepositoryProtocol

    // MARK: - Init

    init(walletRepository: WalletRepositoryProtocol) {
        self.walletRepository = walletRepository
    }

    // MARK: - Actions

    func uploadNFT() async {
        guard isFormValid, let imageData = selectedImageData else { return }

        isLoading = true
        errorMessage = nil

        do {
            try await walletRepository.uploadNFT(
                imageData:   imageData,
                imageName:   "nft_image.jpg",
                title:       title,
                description: nftDescription,
                price:       sellingPrice,
                userId:      "user-001",
                email:       "jane.cooper@example.com"
            )
            showSuccessModal = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func dismissModal() {
        showSuccessModal = false
    }

    // MARK: - Image Handling

    func setImage(_ image: UIImage) {
        let resized = image.resized(toMaxDimension: 1024)
        if let jpeg = resized.jpegData(compressionQuality: 0.7) {
            selectedImageData = jpeg
        } else {
            selectedImageData = image.jpegData(compressionQuality: 0.7)
        }
        selectedImage = resized
    }
}

// MARK: - UIImage Resizing

private extension UIImage {
    func resized(toMaxDimension maxDimension: CGFloat) -> UIImage {
        let size = self.size
        let scale = min(1.0, min(maxDimension / size.width, maxDimension / size.height))
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
