//
//  PurchaseViewModel.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 12/08/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class PurchaseViewModel {

    // MARK: - State

    let nft: NFT
    var usdtBalance: Decimal = 0.0
    private(set) var isLoading: Bool = false
    private(set) var showSuccessModal: Bool = false
    private(set) var errorMessage: String?

    var hasSufficientBalance: Bool {
        usdtBalance >= nft.price
    }

    // MARK: - Dependencies

    private let marketplaceRepository: MarketplaceRepositoryProtocol
    private let walletRepository: WalletRepositoryProtocol

    // MARK: - Init

    init(
        nft: NFT,
        marketplaceRepository: MarketplaceRepositoryProtocol,
        walletRepository: WalletRepositoryProtocol
    ) {
        self.nft = nft
        self.marketplaceRepository = marketplaceRepository
        self.walletRepository = walletRepository
    }

    // MARK: - Actions

    func fetchBalance() async {
        do {
            let balances = try await walletRepository.fetchBalances(
                userId: "user-001",
                email: "jane.cooper@example.com"
            )
            if let usdt = balances.first(where: { $0.symbol == "USDT" }) {
                self.usdtBalance = usdt.balance
            }
        } catch {
            print("Failed to fetch balance: \(error)")
        }
    }

    func purchase() async {
        isLoading = true
        errorMessage = nil

        do {
            try await marketplaceRepository.purchaseNFT(
                id:     nft.id,
                userId: "user-001",
                email:  "jane.cooper@example.com"
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
}
