//
//  AppContainer.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 12/08/26.
//

import Foundation
import Observation

/// Top-level dependency injection container.
///
/// Owns and vends all shared services, repositories, and ViewModels.
@MainActor
@Observable
final class AppContainer {

    // MARK: - Services

    let networkService: NetworkServiceProtocol

    // MARK: - Repositories

    let marketplaceRepository: MarketplaceRepositoryProtocol
    let walletRepository: WalletRepositoryProtocol

    // MARK: - ViewModels

    let marketplaceViewModel: MarketplaceViewModel
    let walletViewModel: WalletViewModel
    let createNFTViewModel: CreateNFTViewModel

    // MARK: - Init

    init() {
        let networkService = NetworkService()
        self.networkService = networkService

        self.marketplaceRepository = MarketplaceRepository(networkService: networkService)
        self.walletRepository      = WalletRepository(networkService: networkService)

        self.marketplaceViewModel  = MarketplaceViewModel(marketplaceRepository: self.marketplaceRepository)
        self.walletViewModel       = WalletViewModel(walletRepository: self.walletRepository)
        self.createNFTViewModel    = CreateNFTViewModel(walletRepository: self.walletRepository)
    }

    // MARK: - Factories

    func makePurchaseViewModel(for nft: NFT) -> PurchaseViewModel {
        return PurchaseViewModel(
            nft: nft,
            marketplaceRepository: self.marketplaceRepository,
            walletRepository: self.walletRepository
        )
    }
}
