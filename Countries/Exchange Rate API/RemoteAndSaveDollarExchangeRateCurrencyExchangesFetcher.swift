//
//  RemoteAndSaveDollarExchangeRateCurrencyExchangesFetcher.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 21/05/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import Foundation

class RemoteAndSaveDollarExchangeRateCurrencyExchangesFetcher:  CurrencyExchangesFetcher {
    private let remote: CurrencyExchangesFetcher
    private let cache: (CurrencyExchange, Currency) -> Void
    
    init(remote: CurrencyExchangesFetcher, cache: @escaping (CurrencyExchange, Currency) -> Void) {
        self.remote = remote
        self.cache = cache
    }
    
    func fetch(for localCurrency: Currency, completion: @escaping (Result<[CurrencyExchange], Error>) -> Void) {
        remote.fetch(for: localCurrency) { [weak self] result in
            switch result {
            case .success(let currencyExchanges):
                guard let currencyExchangeToDollar = currencyExchanges.first(where: {$0.to.code == "USD" }) else { break
                }
                self?.cache(currencyExchangeToDollar, localCurrency)
            case .failure: break
            }
            completion(result)
        }
    }
}
