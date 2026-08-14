//
//  MockData.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 14/08/26.
//

import Foundation

/// Provides seed and fallback data when the remote interview server is down (e.g. 502 Bad Gateway).
final class MockData {

    static var sampleNFTs: [NFT] = [
        NFT(
            id: "1",
            title: "Hypebest Apes B",
            description: "Each Apes NFT is a unique masterpiece, and crafted by artists around the globe.",
            imageUrl: URL(string: "https://images.unsplash.com/photo-1620641788421-7a1c342ea42e?w=800&auto=format&fit=crop&q=80"),
            createdBy: "Theresa Webb",
            price: Decimal(string: "4.75")!,
            currency: "USDT",
            available: true,
            createdAt: Date()
        ),
        NFT(
            id: "2",
            title: "Cyber Samurai #101",
            description: "Futuristic digital warrior exploring the decentralized metaverse.",
            imageUrl: URL(string: "https://images.unsplash.com/photo-1634017839464-5c339ebe3cb4?w=800&auto=format&fit=crop&q=80"),
            createdBy: "Jane Cooper",
            price: Decimal(string: "12.50")!,
            currency: "USDT",
            available: true,
            createdAt: Date()
        ),
        NFT(
            id: "3",
            title: "Golden Skull #42",
            description: "Rare 3D rendered artifact generated on the blockchain.",
            imageUrl: URL(string: "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800&auto=format&fit=crop&q=80"),
            createdBy: "Guy Hawkins",
            price: Decimal(string: "8.20")!,
            currency: "USDT",
            available: true,
            createdAt: Date()
        ),
        NFT(
            id: "4",
            title: "Neon Genesis Ape",
            description: "Glowing cyberpunk character celebrating high-tech decentralized culture.",
            imageUrl: URL(string: "https://images.unsplash.com/photo-1620712943543-bcc4688e7485?w=800&auto=format&fit=crop&q=80"),
            createdBy: "Theresa Webb",
            price: Decimal(string: "6.80")!,
            currency: "USDT",
            available: true,
            createdAt: Date()
        ),
        NFT(
            id: "5",
            title: "Cosmic Astronaut",
            description: "Surreal voyager floating through deep space nebula and digital stars.",
            imageUrl: URL(string: "https://images.unsplash.com/photo-1635322966219-b75ed372eb01?w=800&auto=format&fit=crop&q=80"),
            createdBy: "Robert Fox",
            price: Decimal(string: "15.00")!,
            currency: "USDT",
            available: true,
            createdAt: Date()
        ),
        NFT(
            id: "6",
            title: "Pixel Warrior #09",
            description: "Retro 8-bit warrior with animated holographic armor and sword.",
            imageUrl: URL(string: "https://images.unsplash.com/photo-1637858868799-7f26a0640eb6?w=800&auto=format&fit=crop&q=80"),
            createdBy: "Jane Cooper",
            price: Decimal(string: "3.40")!,
            currency: "USDT",
            available: true,
            createdAt: Date()
        )
    ]

    static var ownedNFTs: [NFT] = [
        NFT(
            id: "owned-1",
            title: "Cyber Samurai #101",
            description: "Futuristic digital warrior exploring the decentralized metaverse.",
            imageUrl: URL(string: "https://images.unsplash.com/photo-1634017839464-5c339ebe3cb4?w=800&auto=format&fit=crop&q=80"),
            createdBy: "Jane Cooper",
            price: Decimal(string: "12.50")!,
            currency: "USDT",
            available: false,
            createdAt: Date()
        ),
        NFT(
            id: "owned-2",
            title: "Neon Genesis Ape",
            description: "Glowing cyberpunk character celebrating high-tech decentralized culture.",
            imageUrl: URL(string: "https://images.unsplash.com/photo-1620712943543-bcc4688e7485?w=800&auto=format&fit=crop&q=80"),
            createdBy: "Jane Cooper",
            price: Decimal(string: "6.80")!,
            currency: "USDT",
            available: false,
            createdAt: Date()
        )
    ]

    static var sampleBalances: [WalletBalance] = [
        WalletBalance(symbol: "USDT", balance: Decimal(string: "50.00")!),
        WalletBalance(symbol: "BNB",  balance: Decimal(string: "2.5412")!),
        WalletBalance(symbol: "ETH",  balance: Decimal(string: "1.2500")!),
        WalletBalance(symbol: "BTC",  balance: Decimal(string: "0.1523")!)
    ]

    static func recordPurchase(id: String) {
        if let nft = sampleNFTs.first(where: { $0.id == id }) {
            if !ownedNFTs.contains(where: { $0.id == nft.id }) {
                ownedNFTs.insert(nft, at: 0)
            }
            // Deduct USDT balance
            if let index = sampleBalances.firstIndex(where: { $0.symbol == "USDT" }) {
                let current = sampleBalances[index].balance
                let newBal = max(0, current - nft.price)
                sampleBalances[index] = WalletBalance(symbol: "USDT", balance: newBal)
            }
        }
    }

    static func addOwnedNFT(title: String, description: String, price: Decimal, imageData: Data) {
        let newNFT = NFT(
            id: "user-nft-\(UUID().uuidString.prefix(6))",
            title: title,
            description: description,
            imageUrl: nil,
            createdBy: "Jane Cooper",
            price: price,
            currency: "USDT",
            available: false,
            createdAt: Date()
        )
        ownedNFTs.insert(newNFT, at: 0)
    }
}
