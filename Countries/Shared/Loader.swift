//
//  Loader.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 20/05/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import Foundation

class Loader {
    func loadCountries() -> [Country]? {
        return NSCountry.loadCountries()
    }
    
    func loadDollarCurrencyExchange(for currency: Currency) -> CurrencyExchange? {
        return NSCurrencyExchange.loadDollarCurrencyExchange(forCurrency: currency)
    }
    
    func loadTimestampedCurrencyExchanges(for currency: Currency) -> TimestampedCurrencyExchanges? {
        return NSTimestampedCurrencyExchanges.loadTimestampedCurrencyExchanges(forCurrency: currency)
    }
}
