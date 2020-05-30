//
//  RemoteAndSaveTimestampedCurrencyExchangesFetcher.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 21/05/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import Foundation

class RemoteAndSaveTimestampedCurrencyExchangesFetcher:  TimestampedCurrencyExchangesFetcher {
    private let remote: RemoteTimestampedCurrencyExchangesFetcher
    private let cache: (TimestampedCurrencyExchanges, Currency) -> Void
    
    init(remote: RemoteTimestampedCurrencyExchangesFetcher, cache: @escaping (TimestampedCurrencyExchanges, Currency) -> Void) {
        self.remote = remote
        self.cache = cache
    }
    
    func fetchTimestamped(for localCurrency: Currency, completion: @escaping (Result<TimestampedCurrencyExchanges, Error>) -> Void) {
        remote.fetchTimestamped(for: localCurrency) { [weak self] result in
            switch result {
            case .success(let timestampedCurrencyExchanges):
                self?.cache(timestampedCurrencyExchanges, localCurrency)
            case .failure: break
            }
            completion(result)
        }
    }
}
