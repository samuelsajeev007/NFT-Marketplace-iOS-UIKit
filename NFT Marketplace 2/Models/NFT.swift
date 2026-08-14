//
//  NFT.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 12/08/26.
//

import Foundation

// MARK: - NFT

/// Represents a single Non-Fungible Token available in the marketplace.
struct NFT: Identifiable, Hashable, Sendable {

    let id: String
    let title: String
    let description: String?
    let imageUrl: URL?
    let createdBy: String
    let price: Decimal
    let currency: String?
    let available: Bool
    let createdAt: Date?
}

// MARK: - Codable

extension NFT: Codable {

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case description
        case imageUrl
        case createdBy
        case price
        case currency
        case available
        case createdAt
    }

    nonisolated init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id          = try container.decode(String.self,   forKey: .id)
        title       = try container.decode(String.self,   forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        imageUrl    = try container.decodeIfPresent(URL.self,    forKey: .imageUrl)
        createdBy   = try container.decode(String.self,   forKey: .createdBy)
        price       = try container.decode(Decimal.self,  forKey: .price)
        currency    = try container.decodeIfPresent(String.self, forKey: .currency)
        available   = try container.decode(Bool.self,     forKey: .available)

        let dateString = try container.decodeIfPresent(String.self, forKey: .createdAt)
        if let dateString = dateString {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            createdAt = formatter.date(from: dateString)
        } else {
            createdAt = nil
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id,          forKey: .id)
        try container.encode(title,       forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(imageUrl,    forKey: .imageUrl)
        try container.encode(createdBy,   forKey: .createdBy)
        try container.encode(price,       forKey: .price)
        try container.encodeIfPresent(currency,    forKey: .currency)
        try container.encode(available,   forKey: .available)

        if let createdAt = createdAt {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
        }
    }
}
