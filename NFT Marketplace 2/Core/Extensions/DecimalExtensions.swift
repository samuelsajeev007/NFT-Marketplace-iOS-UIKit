//
//  DecimalExtensions.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 12/08/26.
//

import Foundation

extension Decimal {

    // MARK: - Currency Formatting

    var formattedAsUSDT: String {
        formatted(currencyCode: AppConstants.Currency.purchaseCurrencySymbol)
    }

    func formatted(currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle         = .decimal
        formatter.minimumFractionDigits = AppConstants.Currency.usdtDecimalPlaces
        formatter.maximumFractionDigits = AppConstants.Currency.usdtDecimalPlaces
        formatter.groupingSeparator   = ","
        formatter.usesGroupingSeparator = true

        let numberString = formatter.string(from: self as NSDecimalNumber) ?? "\(self)"
        return "\(numberString) \(currencyCode)"
    }
}
