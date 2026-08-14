//
//  ViewState.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 12/08/26.
//

import Foundation

// MARK: - ViewState

/// Generic state machine for async data-loading scenarios.
enum ViewState<T> {

    case idle
    case loading
    case loaded(T)
    case error(String)

    var data: T? {
        if case .loaded(let value) = self { return value }
        return nil
    }

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }
}

// MARK: - WalletTab

enum WalletTab: String, CaseIterable {
    case myNFTs = "My NFTs"
    case coins  = "Coins"
}
