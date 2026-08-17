//
//  AppRoute.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 17/08/26.
//

import Foundation

/// Represents all navigable destinations in the application in a type-safe manner.
enum AppRoute {
    case home
    case nftDetail(nft: NFT)
    case purchaseConfirmation(nft: NFT)
    case createNFT
    case successModal(
        title: String,
        message: String,
        buttonTitle: String,
        showArrow: Bool,
        onAction: (() -> Void)? = nil
    )
}
