//
//  User.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 12/08/26.
//

import Foundation

// MARK: - User

/// Represents the authenticated user of the application.
struct User: Identifiable, Codable, Hashable {

    let id: String
    let displayName: String
    let email: String
    let avatarURL: URL?

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case email
        case avatarURL   = "avatar_url"
    }
}
