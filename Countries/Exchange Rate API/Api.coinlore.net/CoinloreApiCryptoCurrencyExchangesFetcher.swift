//
//  CoinloreApiCryptoExchangeRateFetcher.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 29/03/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import Foundation

class CoinloreApiCryptoCurrencyExchangesFetcher: TimestampedCurrencyExchangesFetcher {
    private let client: HTTPClient
    private let localToUsdFetcher: CurrencyExchangesFetcher

    private let toCurrency = Currency(code: "USD", symbol: "$", name: "United States dollar", type: .fiat)
    private var timestamps: [Timestamp] = []
    
    init(client: HTTPClient, localToUsdFetcher: CurrencyExchangesFetcher) {
        self.client = client
        self.localToUsdFetcher = localToUsdFetcher
    }
    
    func fetchTimestamped(for localCurrency: Currency, completion: @escaping (Result<TimestampedCurrencyExchanges, Error>) -> Void) {
        guard let url = CoinloreApiCryptoCurrencyExchangesFetcher.url() else {
            return completion(.failure(Error.invalidData))
        }

        client.downloadData(from: url) { [weak self] result in
            switch result {
            case .success(let data):
                self?.calculateExchange(for: localCurrency,from: data) { result in
                    switch result {
                    case .success(let exchangeRates):
                        var currencyExchanges = [CurrencyExchange]()
                        for key in exchangeRates.keys {
                            guard let exchangeRate = exchangeRates[key] else {
                                return completion(.failure(Error.invalidData))
                            }
                            currencyExchanges.append(CurrencyExchange(from: localCurrency,
                                                                      to: key,
                                                                      exchangeRate: exchangeRate))
                        }
                        let timestampedCurrencyExchanges = TimestampedCurrencyExchanges(currencyExchanges: currencyExchanges, timestamps: self?.timestamps ?? [])
                        completion(.success(timestampedCurrencyExchanges))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
     }
     
     private static func url() -> URL? {
         return URL(string: "https://api.coinlore.net/api/tickers/?start=0&limit=10")
     }
    
    private func calculateExchange(for localCurrency: Currency, from data: Data, completion: @escaping (Result<[Currency: Double], Error>) -> Void) {
        fetchCryptosToUsdExchangeRate(from: data) { [weak self] result in
            switch result {
            case .success(let cryptoCurrencyResponses):
                self?.localToUsdFetcher.fetch(for: localCurrency) { [weak self] result in
                    switch result {
                    case .success(let currencyExchangeRates):
                        if let localToUsdExchangeRate = currencyExchangeRates.first(where: {$0.to.code == self?.toCurrency.code }) {
                            var localToCryptoExchangeRates = [Currency: Double]()
                            cryptoCurrencyResponses.forEach { response in
                                localToCryptoExchangeRates[response.currency] = localToUsdExchangeRate.exchangeRate/response.usdExchangeRate
                            }
                            completion(.success(localToCryptoExchangeRates))
                        } else {
                            completion(.failure(Error.invalidData))
                        }
                    case .failure:
                        completion(.failure(Error.invalidData))
                    }
                }
            case .failure:
                completion(.failure(Error.invalidData))
            }
        }
    }
     
    private func fetchCryptosToUsdExchangeRate(from data: Data, completion: @escaping (Result<([CryptoCurrencyResponse]), Error>) -> Void) {
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let cryptos = json["data"] as? [[String: Any]],
            let info = json["info"] as? [String: Any],
            let timestamp = info["time"] as? Int
        else { return completion(.failure(Error.invalidData)) }
        let date = Date(timeIntervalSince1970: Double(timestamp))
        timestamps = [Timestamp(currencyType: .crypto, date: date)]
        let cryptoCurrencyResponses = map(cryptos)
            
        return completion(.success(cryptoCurrencyResponses))
    }

    private func map(_ cryptos: [[String: Any]]) -> [CryptoCurrencyResponse] {
        let cryptoCurrenciesResponses = cryptos.compactMap { crypto in
            self.mapCryptoCurrency(crypto)
        }
        
        return cryptoCurrenciesResponses
    }
    
    private func mapCryptoCurrency(_ cryptoCurrency: [String: Any]) -> CryptoCurrencyResponse? {
        guard
            let code = cryptoCurrency["symbol"] as? String,
            let symbol = cryptoCurrency["symbol"] as? String,
            let name = cryptoCurrency["name"] as? String,
            let usdPriceString = cryptoCurrency["price_usd"] as? String
        else { return nil }
        
        guard let usdPrice = Double(usdPriceString) else { return nil }
        let currency = Currency(code: code, symbol: symbol, name: name, type: .crypto)
        
        return CryptoCurrencyResponse(currency: currency, usdExchangeRate: usdPrice)
    }
}
