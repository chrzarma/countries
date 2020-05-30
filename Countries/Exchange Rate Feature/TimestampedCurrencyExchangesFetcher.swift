//
//  TimestampedCurrencyExchangesFetcher.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 09/04/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import Foundation

protocol TimestampedCurrencyExchangesFetcher {
    func fetchTimestamped(for localCurrency: Currency, completion: @escaping (Result<TimestampedCurrencyExchanges, Error>) -> Void)
}
