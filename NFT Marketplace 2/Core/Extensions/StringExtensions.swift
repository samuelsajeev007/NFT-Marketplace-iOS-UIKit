//
//  StringExtensions.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 12/08/26.
//

import Foundation

extension String {

    var isNotBlank: Bool {
        !trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func truncated(to maxLength: Int) -> String {
        guard count > maxLength else { return self }
        return String(prefix(maxLength)) + "…"
    }
}
