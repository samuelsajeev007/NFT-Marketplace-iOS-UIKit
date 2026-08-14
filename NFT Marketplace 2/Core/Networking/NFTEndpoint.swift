//
//  NFTEndpoint.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 12/08/26.
//

import Foundation

/// Defines all API endpoints used by the NFT Marketplace.
enum NFTEndpoint {

    // MARK: - Marketplace
    case listNFTs
    case nftDetail(id: String)
    case purchaseNFT(nftID: String, userId: String, email: String)

    // MARK: - Wallet
    case walletBalances(userid: String, email: String)
    case ownedNFTs(userid: String, email: String)
    case uploadNFT(
        imageData: Data,
        imageName: String,
        title: String,
        description: String,
        price: String,
        userid: String,
        email: String
    )

    // MARK: - Path Resolution

    var path: String {
        switch self {
        case .listNFTs:                     return "/beetobeeGetProducts"
        case .nftDetail(let id):            return "/nfts/\(id)"
        case .purchaseNFT:                  return "/beetobeeBuyNft"
        case .walletBalances:               return "/beetobeeMywalletBalance"
        case .ownedNFTs:                    return "/beetobeeMyNfts"
        case .uploadNFT:                    return "/beetobeeNftUpload"
        }
    }

    var httpMethod: String {
        switch self {
        case .listNFTs, .nftDetail, .walletBalances, .ownedNFTs: return "GET"
        case .purchaseNFT, .uploadNFT:                           return "POST"
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .ownedNFTs(let userid, let email),
             .walletBalances(let userid, let email):
            return [
                URLQueryItem(name: "userid", value: userid),
                URLQueryItem(name: "email",  value: email)
            ]
        default: return nil
        }
    }
}
