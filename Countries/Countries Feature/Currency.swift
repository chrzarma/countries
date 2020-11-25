//
//  Currency.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 20/03/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import Foundation

enum CurrencyType {
    case fiat, crypto
    
    static func getString(from type: CurrencyType) -> String {
        switch type {
        case .fiat:
            return "fiat"
        case .crypto:
            return "crypto"
        }
    }
    
    static func create(from string: String) -> CurrencyType {
        switch string {
        case "fiat":
            return .fiat
        default:
            return .crypto
        }
    }
}

struct Currency: Hashable {
    let code: String
    let symbol: String
    let name: String
    let type: CurrencyType
}

class NSCurrency: NSObject, NSCoding {
    var currency: Currency

    init(currency: Currency) {
        self.currency = currency
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        guard let code = aDecoder.decodeObject(forKey: "code") as? String,
            let symbol = aDecoder.decodeObject(forKey: "symbol") as? String,
            let name = aDecoder.decodeObject(forKey: "name") as? String,
            let type = aDecoder.decodeObject(forKey: "type") as? String else { return nil }

        currency = Currency(code: code, symbol: symbol, name: name, type: CurrencyType.create(from: type))
        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(currency.code, forKey: "code")
        aCoder.encode(currency.symbol, forKey: "symbol")
        aCoder.encode(currency.name, forKey: "name")
        aCoder.encode(CurrencyType.getString(from: currency.type), forKey: "type")
    }
}
