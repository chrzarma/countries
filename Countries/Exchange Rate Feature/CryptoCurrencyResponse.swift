//
//  CryptoCurrencyResponse.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 28/03/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import Foundation

struct CryptoCurrencyResponse: Hashable {
    let currency: Currency
    let usdExchangeRate: Double
}
