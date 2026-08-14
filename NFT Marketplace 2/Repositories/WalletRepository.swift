//
//  WalletRepository.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 12/08/26.
//

import Foundation

// MARK: - WalletRepositoryProtocol

protocol WalletRepositoryProtocol {
    func fetchBalances(userId: String, email: String) async throws -> [WalletBalance]
    func uploadNFT(
        imageData: Data,
        imageName: String,
        title: String,
        description: String,
        price: String,
        userId: String,
        email: String
    ) async throws
    func fetchOwnedNFTs(userId: String, email: String) async throws -> [NFT]
}

// MARK: - WalletRepository

final class WalletRepository: WalletRepositoryProtocol {

    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchBalances(userId: String, email: String) async throws -> [WalletBalance] {
        do {
            let response = try await networkService.request(
                endpoint: .walletBalances(userid: userId, email: email),
                responseType: WalletBalanceResponse.self
            )
            if !response.coins.isEmpty {
                return response.coins
            }
        } catch {
            print("Remote balances error: \(error). Using fallback balances.")
        }
        return MockData.sampleBalances
    }

    func uploadNFT(
        imageData: Data,
        imageName: String,
        title: String,
        description: String,
        price: String,
        userId: String,
        email: String
    ) async throws {
        do {
            _ = try await networkService.request(
                endpoint: .uploadNFT(
                    imageData:   imageData,
                    imageName:   imageName,
                    title:       title,
                    description: description,
                    price:       price,
                    userid:      userId,
                    email:       email
                ),
                responseType: EmptyResponse.self
            )
            MockData.addOwnedNFT(title: title, description: description, price: Decimal(string: price) ?? 10.0, imageData: imageData)
        } catch {
            print("Remote upload error: \(error). Adding to local owned NFTs.")
            MockData.addOwnedNFT(title: title, description: description, price: Decimal(string: price) ?? 10.0, imageData: imageData)
        }
    }

    func fetchOwnedNFTs(userId: String, email: String) async throws -> [NFT] {
        do {
            let response = try await networkService.request(
                endpoint: .ownedNFTs(userid: userId, email: email),
                responseType: NFTResponse.self
            )
            if !response.items.isEmpty {
                return response.items
            }
        } catch {
            print("Remote owned NFTs error: \(error). Using fallback owned dataset.")
        }
        return MockData.ownedNFTs
    }
}
