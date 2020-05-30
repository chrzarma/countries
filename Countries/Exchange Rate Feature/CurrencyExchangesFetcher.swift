//
//  ExchangeRateFetcher.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 21/03/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import Foundation

protocol CurrencyExchangesFetcher {
    func fetch(for localCurrency: Currency, completion: @escaping (Result<[CurrencyExchange], Error>) -> Void)
}
