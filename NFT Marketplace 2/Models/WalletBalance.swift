//
//  WalletBalance.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 12/08/26.
//

import Foundation

// MARK: - WalletBalance

struct WalletBalance: Identifiable, Hashable, Sendable {

    var id: String { symbol }
    let symbol: String
    let balance: Decimal
}

// MARK: - Codable

extension WalletBalance: Codable {

    enum CodingKeys: String, CodingKey {
        case symbol
        case balance
    }

    nonisolated init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        symbol  = try container.decode(String.self,  forKey: .symbol)
        balance = try container.decode(Decimal.self, forKey: .balance)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(symbol,  forKey: .symbol)
        try container.encode(balance, forKey: .balance)
    }
}
