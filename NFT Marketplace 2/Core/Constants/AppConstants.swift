//
//  AppConstants.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 12/08/26.
//

import Foundation

enum AppConstants {

    // MARK: - API

    enum API {
        static let baseURL = "https://nodeapi.techbank.live/interview/v2"
        static let apiKey  = "user-key"
        static let timeoutInterval: TimeInterval = 30
    }

    // MARK: - Currency

    enum Currency {
        static let purchaseCurrencySymbol = "USDT"
        static let usdtDecimalPlaces = 2
    }

    // MARK: - Pagination

    enum Pagination {
        static let defaultPageSize = 20
    }

    // MARK: - UI

    enum UI {
        static let defaultAnimationDuration: Double = 0.25
    }
}
