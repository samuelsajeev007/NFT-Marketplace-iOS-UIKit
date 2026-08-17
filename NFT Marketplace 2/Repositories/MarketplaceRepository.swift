//
//  MarketplaceRepository.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 12/08/26.
//

import Foundation

// MARK: - MarketplaceRepositoryProtocol

/// Contract for all marketplace data operations strictly via API.
protocol MarketplaceRepositoryProtocol {
    func fetchNFTs(page: Int, pageSize: Int) async throws -> [NFT]
    func fetchNFTDetail(id: String) async throws -> NFT
    func purchaseNFT(id: String, userId: String, email: String) async throws
    func purchaseNFT(nft: NFT, userId: String, email: String) async throws
}

// MARK: - MarketplaceRepository

/// Pure API implementation of MarketplaceRepositoryProtocol.
final class MarketplaceRepository: MarketplaceRepositoryProtocol {

    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchNFTs(page: Int, pageSize: Int) async throws -> [NFT] {
        let response = try await networkService.request(
            endpoint: .listNFTs,
            responseType: NFTResponse.self
        )
        return response.items
    }

    func fetchNFTDetail(id: String) async throws -> NFT {
        try await networkService.request(
            endpoint: .nftDetail(id: id),
            responseType: NFT.self
        )
    }

    func purchaseNFT(id: String, userId: String, email: String) async throws {
        _ = try await networkService.request(
            endpoint: .purchaseNFT(nftID: id, userId: userId, email: email),
            responseType: EmptyResponse.self
        )
    }

    func purchaseNFT(nft: NFT, userId: String, email: String) async throws {
        try await purchaseNFT(id: nft.id, userId: userId, email: email)
    }
}
