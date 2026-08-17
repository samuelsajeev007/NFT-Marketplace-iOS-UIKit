//
//  CreateNFTViewModel.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 12/08/26.
//

import Foundation
import UIKit
import Observation

@MainActor
@Observable
final class CreateNFTViewModel {

    // MARK: - Form State

    var title: String = ""
    var nftDescription: String = ""
    var sellingPrice: String = ""
    var selectedImage: UIImage?
    var selectedImageData: Data?

    // MARK: - Loading & Error State

    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    private(set) var showSuccessModal: Bool = false

    // MARK: - Validation

    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !sellingPrice.trimmingCharacters(in: .whitespaces).isEmpty &&
        (Decimal(string: sellingPrice.trimmingCharacters(in: .whitespaces)) ?? 0) > 0 &&
        selectedImageData != nil
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

    func resetForm() {
        title = ""
        nftDescription = ""
        sellingPrice = ""
        selectedImage = nil
        selectedImageData = nil
        errorMessage = nil
        showSuccessModal = false
    }

    // MARK: - Image Handling & Compression

    func setImage(_ image: UIImage) {
        // Multi-stage image compression to keep upload efficient & fast
        let resized = image.resized(toMaxDimension: 1024)
        var quality: CGFloat = 0.7
        var compressedData = resized.jpegData(compressionQuality: quality)

        while let data = compressedData, data.count > 800 * 1024, quality > 0.3 {
            quality -= 0.1
            compressedData = resized.jpegData(compressionQuality: quality)
        }

        selectedImageData = compressedData ?? image.jpegData(compressionQuality: 0.5)
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
