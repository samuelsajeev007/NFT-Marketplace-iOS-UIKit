//
//  NFTResponse.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 12/08/26.
//

import Foundation

/// A wrapper to decode the root API response which contains an array of NFTs.
struct NFTResponse: Codable, Sendable {
    let items: [NFT]
}
