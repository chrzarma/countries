//
//  CountriesFetchDelegate.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 17/05/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import Foundation

protocol CountriesFetchDelegate {
    func didFetch(countries: [Country])
    func failedToFetch(with error: Error)
}
