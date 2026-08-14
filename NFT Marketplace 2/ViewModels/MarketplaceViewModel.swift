//
//  MarketplaceViewModel.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 12/08/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class MarketplaceViewModel {

    // MARK: - Observable State

    private(set) var nfts: [NFT] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?

    // MARK: - Pagination State

    private var currentPage = 1
    private var hasMorePages = true

    // MARK: - Dependencies

    private let marketplaceRepository: MarketplaceRepositoryProtocol

    // MARK: - Init

    init(marketplaceRepository: MarketplaceRepositoryProtocol) {
        self.marketplaceRepository = marketplaceRepository
    }

    // MARK: - Intent Handlers

    func loadNFTs() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        currentPage = 1
        hasMorePages = true

        do {
            let fetchedNFTs = try await marketplaceRepository.fetchNFTs(
                page: currentPage,
                pageSize: AppConstants.Pagination.defaultPageSize
            )
            nfts = fetchedNFTs
            hasMorePages = fetchedNFTs.count == AppConstants.Pagination.defaultPageSize
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadMoreIfNeeded(currentItem nft: NFT) async {
        guard !isLoading,
              hasMorePages,
              let index = nfts.firstIndex(of: nft),
              index == nfts.count - 3 else { return }

        isLoading = true
        currentPage += 1

        do {
            let fetchedNFTs = try await marketplaceRepository.fetchNFTs(
                page: currentPage,
                pageSize: AppConstants.Pagination.defaultPageSize
            )
            nfts.append(contentsOf: fetchedNFTs)
            hasMorePages = fetchedNFTs.count == AppConstants.Pagination.defaultPageSize
        } catch {
            currentPage -= 1
        }

        isLoading = false
    }
}
