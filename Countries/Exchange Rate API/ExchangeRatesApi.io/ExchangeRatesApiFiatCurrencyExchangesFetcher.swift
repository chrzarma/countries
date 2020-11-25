//
//  ExchangeRatesApiExchangeRateFetcher.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 20/03/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import Foundation

class ExchangeRatesApiFiatCurrencyExchangesFetcher: CurrencyExchangesFetcher, TimestampedCurrencyExchangesFetcher {
    private let client: HTTPClient
    private let allCurrencies: [Currency]
    
    init(client: HTTPClient, allCurrencies: [Currency]) {
        self.client = client
        self.allCurrencies = allCurrencies
    }
    
    func fetch(for localCurrency: Currency, completion: @escaping (Result<[CurrencyExchange], Error>) -> Void) {
        guard let url = ExchangeRatesApiFiatCurrencyExchangesFetcher.url(for: localCurrency.code) else {
            return completion(.failure(Error.invalidURL))
        }
        
        client.downloadData(from: url) { [weak self] result in
            switch result {
            case .success(let data):
                if let currencyExchanges = ExchangeRatesApiFiatCurrencyExchangesFetcher.calculateExchanges(for: localCurrency, from: data, allCurrencies: self?.allCurrencies ?? []) {
                    let sortedCurrencyExchanges = currencyExchanges.sorted {
                        $0.exchangeRate < $1.exchangeRate
                    }
                    completion(.success(sortedCurrencyExchanges))
                } else {
                    completion(.failure(Error.invalidData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchTimestamped(for localCurrency: Currency, completion: @escaping (Result<TimestampedCurrencyExchanges, Error>) -> Void) {
        guard let url = ExchangeRatesApiFiatCurrencyExchangesFetcher.url(for: localCurrency.code) else {
            return completion(.failure(Error.invalidURL))
        }
        
        client.downloadData(from: url) { [weak self] result in
            switch result {
            case .success(let data):
                if let timestampedCurrencyExchanges = ExchangeRatesApiFiatCurrencyExchangesFetcher.calculateTimestampedExchanges(for: localCurrency, from: data, allCurrencies: self?.allCurrencies ?? []) {
                    completion(.success(timestampedCurrencyExchanges))
                } else {
                    completion(.failure(Error.invalidData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
     
    
    private static func url(for base: String) -> URL? {
        var components = URLComponents(string: "https://api.exchangeratesapi.io/latest")
        components?.queryItems = [URLQueryItem(name: "base", value: base)]
        return components?.url
    }
    
    private static func calculateExchanges(for localCurrency: Currency, from data: Data, allCurrencies: [Currency]) -> [CurrencyExchange]? {
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let rates = json["rates"] as? [String: Double]
        else { return nil }
        var currencyExchanges = [CurrencyExchange]()
        rates.forEach { rate in
            if let currency = allCurrencies.first(where: {$0.code == rate.key }) {
                let currencyExchange = CurrencyExchange(from: localCurrency, to: currency, exchangeRate: rate.value)
                currencyExchanges.append(currencyExchange)
            }
        }
                           
        return currencyExchanges
    }
    
    private static func calculateTimestampedExchanges(for localCurrency: Currency, from data: Data, allCurrencies: [Currency]) -> TimestampedCurrencyExchanges? {
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            return formatter
        }()
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let rates = json["rates"] as? [String: Double],
            let dateString = json["date"] as? String
        else { return nil }
        var currencyExchanges = [CurrencyExchange]()
        rates.forEach { rate in
            if let currency = allCurrencies.first(where: {$0.code == rate.key }) {
                let currencyExchange = CurrencyExchange(from: localCurrency, to: currency, exchangeRate: rate.value)
                currencyExchanges.append(currencyExchange)
            }
        }
        
        let dateStringWithTime = dateString + " 16:00"
        guard let date = dateFormatter.date(from: dateStringWithTime) else {
            return TimestampedCurrencyExchanges(currencyExchanges: currencyExchanges, timestamps: [])
        }
        let timestamps = [Timestamp(currencyType: .fiat, date: date)]
        return TimestampedCurrencyExchanges(currencyExchanges: currencyExchanges, timestamps: timestamps)
    }
}
