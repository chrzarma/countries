//
//  CapitalCurrentWeatherFetcher.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 15/03/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import Foundation

protocol CapitalCurrentWeatherFetcher {
    func fetch(_ capital: String, completion: @escaping (Result<CapitalWeather, Error>) -> Void)
}
