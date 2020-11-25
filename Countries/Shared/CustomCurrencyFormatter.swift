//
//  CustomCurrencyFormatter.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 16/11/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import Foundation

final class CustomCurrencyFormatter {
    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    static func input(_ input: String) -> String? {
        guard let value = Decimal(string: input) else { return nil }
        
        if value < 1 {
            numberFormatter.maximumSignificantDigits = 2
            return numberFormatter.string(from: (value as NSDecimalNumber))
        }
        
        return "\(value.round(scale: 2, mode: .plain))"
    }
}

extension Decimal {
    func round(scale: Int, mode: NSDecimalNumber.RoundingMode) -> Decimal {
        var result: Decimal = 0
        var mutableValue = self
        NSDecimalRound(&result, &mutableValue, scale, mode)
        return result
    }
}
