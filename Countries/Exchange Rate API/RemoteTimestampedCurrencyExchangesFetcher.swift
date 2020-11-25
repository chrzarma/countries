//
//  RemoteTimestampedCurrencyExchangesFetcher.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 30/03/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import Foundation

class RemoteTimestampedCurrencyExchangesFetcher: TimestampedCurrencyExchangesFetcher {
    private let client: HTTPClient
    private let fiatFetcher: TimestampedCurrencyExchangesFetcher
    private let cryptoFetcher: TimestampedCurrencyExchangesFetcher
    
    init(client: HTTPClient, fiatFetcher: TimestampedCurrencyExchangesFetcher, cryptoFetcher: TimestampedCurrencyExchangesFetcher) {
        self.client = client
        self.fiatFetcher = fiatFetcher
        self.cryptoFetcher = cryptoFetcher
    }
    
    func fetchTimestamped(for localCurrency: Currency, completion: @escaping (Result<TimestampedCurrencyExchanges, Error>) -> Void) {
        fiatFetcher.fetchTimestamped(for: localCurrency) { [weak self] result in
            switch result {
            case .success(let fiatTimestampedExchangeRates):
                self?.cryptoFetcher.fetchTimestamped(for: localCurrency) { result in
                    switch result {
                    case .success(let cryptoTimestampedExchangeRates):
                        completion(.success(RemoteTimestampedCurrencyExchangesFetcher.sortedTimestampedExchangeRates(from: fiatTimestampedExchangeRates, and: cryptoTimestampedExchangeRates)))
                    case .failure:
                        completion(.failure(Error.invalidData))
                    }
                }
            case .failure:
                completion(.failure(Error.invalidData))
            }
        }
    }
    
    private static func sortedTimestampedExchangeRates(from fiat: TimestampedCurrencyExchanges, and cryptos: TimestampedCurrencyExchanges) -> TimestampedCurrencyExchanges {
        let currencyExchanges = (fiat.currencyExchanges + cryptos.currencyExchanges).filter({ $0.to.code != $0.from.code }).sorted { $0.exchangeRate < $1.exchangeRate }
        guard let fiatTimestamp = fiat.timestamps.first, let cryptosTimestamp = cryptos.timestamps.first else {
                return TimestampedCurrencyExchanges(currencyExchanges: currencyExchanges, timestamps: [])
        }
        
        let timestamps = [fiatTimestamp, cryptosTimestamp]
        
        return TimestampedCurrencyExchanges(currencyExchanges: currencyExchanges, timestamps: timestamps)
    }
}
