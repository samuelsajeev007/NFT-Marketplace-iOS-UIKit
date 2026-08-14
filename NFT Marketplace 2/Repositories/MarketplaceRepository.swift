//
//  MarketplaceRepository.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 12/08/26.
//

import Foundation

// MARK: - MarketplaceRepositoryProtocol

protocol MarketplaceRepositoryProtocol {
    func fetchNFTs(page: Int, pageSize: Int) async throws -> [NFT]
    func fetchNFTDetail(id: String) async throws -> NFT
    func purchaseNFT(id: String, userId: String, email: String) async throws
}

// MARK: - MarketplaceRepository

final class MarketplaceRepository: MarketplaceRepositoryProtocol {

    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchNFTs(page: Int, pageSize: Int) async throws -> [NFT] {
        do {
            let response = try await networkService.request(
                endpoint: .listNFTs,
                responseType: NFTResponse.self
            )
            if !response.items.isEmpty {
                return response.items
            }
        } catch {
            print("Remote fetch failed with error: \(error). Using fallback dataset.")
        }
        return MockData.sampleNFTs
    }

    func fetchNFTDetail(id: String) async throws -> NFT {
        do {
            return try await networkService.request(
                endpoint: .nftDetail(id: id),
                responseType: NFT.self
            )
        } catch {
            if let mock = MockData.sampleNFTs.first(where: { $0.id == id }) {
                return mock
            }
            if let owned = MockData.ownedNFTs.first(where: { $0.id == id }) {
                return owned
            }
            throw error
        }
    }

    func purchaseNFT(id: String, userId: String, email: String) async throws {
        do {
            _ = try await networkService.request(
                endpoint: .purchaseNFT(nftID: id, userId: userId, email: email),
                responseType: EmptyResponse.self
            )
            MockData.recordPurchase(id: id)
        } catch {
            print("Remote purchase error: \(error). Recording purchase in local storage.")
            MockData.recordPurchase(id: id)
        }
    }
}
