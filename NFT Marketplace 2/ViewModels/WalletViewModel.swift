//
//  WalletViewModel.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 12/08/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class WalletViewModel {

    // MARK: - Observable State

    private(set) var ownedNFTs: [NFT] = []
    private(set) var balances: [WalletBalance] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?

    // MARK: - Computed

    var usdtBalance: WalletBalance? {
        balances.first { $0.symbol == AppConstants.Currency.purchaseCurrencySymbol }
    }

    // MARK: - Dependencies

    private let walletRepository: WalletRepositoryProtocol

    // MARK: - Init

    init(walletRepository: WalletRepositoryProtocol) {
        self.walletRepository = walletRepository
    }

    // MARK: - Intent Handlers

    func loadWalletData() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            async let fetchedNFTs      = walletRepository.fetchOwnedNFTs(userId: "user-001", email: "jane.cooper@example.com")
            async let fetchedBalances  = walletRepository.fetchBalances(userId: "user-001",  email: "jane.cooper@example.com")

            ownedNFTs = try await fetchedNFTs
            balances  = try await fetchedBalances
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
