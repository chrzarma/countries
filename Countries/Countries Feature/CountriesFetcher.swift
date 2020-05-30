//
//  CountriesFetcher.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 17/05/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import Foundation

protocol CountriesFetcher {
    func fetch(completion: @escaping (Result<[Country], Error>) -> Void)
}
