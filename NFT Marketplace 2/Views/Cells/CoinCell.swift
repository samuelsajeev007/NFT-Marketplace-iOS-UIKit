//
//  CoinCell.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 14/08/26.
//

import UIKit

/// Table view cell displaying a cryptocurrency balance row — loaded from CoinCell.xib.
final class CoinCell: UITableViewCell {

    static let reuseIdentifier = "CoinCell"
    static let nibName = "CoinCell"

    // MARK: - IBOutlets

    @IBOutlet weak var cardBackground: UIView!
    @IBOutlet weak var coinIconImageView: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var fiatLabel: UILabel!
    @IBOutlet weak var chevronImageView: UIImageView!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardBackground.backgroundColor = .coinCellBackground
        cardBackground.layer.cornerRadius = 12
        cardBackground.clipsToBounds = true

        coinIconImageView.layer.cornerRadius = 20
        coinIconImageView.clipsToBounds = true

        chevronImageView.image = UIImage(systemName: "chevron.right")
        chevronImageView.tintColor = .techbankBlue

        symbolLabel.font = UIFont(name: "Poppins-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        balanceLabel.font = UIFont(name: "Poppins-Medium", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .medium)
        fiatLabel.font = UIFont(name: "Poppins-Medium", size: 10) ?? UIFont.systemFont(ofSize: 10, weight: .medium)
    }

    // MARK: - Configure

    func configure(with balance: WalletBalance) {
        symbolLabel.text = balance.symbol
        coinIconImageView.image = UIImage(named: balance.symbol)

        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 4
        let formattedBalance = formatter.string(from: balance.balance as NSDecimalNumber) ?? "0"
        balanceLabel.text = "\(formattedBalance) \(balance.symbol)"

        fiatLabel.text = mockFiatValue(for: balance.symbol)
    }

    private func mockFiatValue(for symbol: String) -> String {
        switch symbol {
        case "BNB":  return "$323245453"
        case "ETH":  return "$87324545"
        case "BTC":  return "$323245453"
        case "USDT": return "$87324545"
        default:     return "$0"
        }
    }
}
