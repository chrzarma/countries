//
//  CountriesFetch.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 24/02/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import Foundation

class CountriesFetch: Fetcher {
    private let client: HTTPClient
    private static let url: URL(string: "https://restcountries.eu/rest/v2/all")
    
    func fetch(completion: @escaping (Result<Data, Error>) -> Void) {
        <#code#>
    }
}
