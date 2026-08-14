//
//  NFTCollectionViewCell.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 14/08/26.
//

import UIKit

/// Collection view cell showing an NFT card — loaded from NFTCollectionViewCell.xib.
final class NFTCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "NFTCollectionViewCell"
    static let nibName = "NFTCollectionViewCell"

    // MARK: - IBOutlets

    @IBOutlet weak var nftImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        nftImageView.layer.cornerRadius = 12
        nftImageView.clipsToBounds = true
        titleLabel.font = UIFont(name: "Poppins-Medium", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .medium)
        priceLabel.font = UIFont(name: "Poppins-SemiBold", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .semibold)
    }

    // MARK: - Configure

    func configure(with nft: NFT) {
        titleLabel.text = nft.title
        priceLabel.text = nft.price.formattedAsUSDT
        nftImageView.loadImage(from: nft.imageUrl)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nftImageView.cancelImageLoad()
        nftImageView.image = nil
        titleLabel.text = nil
        priceLabel.text = nil
    }
}
