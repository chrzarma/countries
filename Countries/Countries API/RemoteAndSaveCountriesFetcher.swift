//
//  RemoteAndSaveCountriesFetcher.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 17/05/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import Foundation

class RemoteAndSaveCountriesFetcher: CountriesFetcher {
    private let remote: RemoteCountriesFetcher
    private let cache: ([Country]) -> Void
    
    init(remote: RemoteCountriesFetcher, cache: @escaping ([Country]) -> Void) {
        self.remote = remote
        self.cache = cache
    }
    
    func fetch(completion: @escaping (Result<[Country], Error>) -> Void) {
        remote.fetch { [weak self] result in
            switch result {
            case .success(let countries):
                self?.cache(countries)
            case .failure: break
            }
            completion(result)
        }
    }
}
