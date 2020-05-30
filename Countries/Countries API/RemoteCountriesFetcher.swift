//
//  RemoteCountriesFetcher.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 24/02/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import Foundation

class RemoteCountriesFetcher: CountriesFetcher {
    private let client: HTTPClient
    private let fetchDelegate: CountriesFetchDelegate
    private let url = URL(string: "https://restcountries.eu/rest/v2/all")!
    private var allCountries = [Country]()
    
    init(client: HTTPClient, fetchDelegate: CountriesFetchDelegate) {
        self.client = client
        self.fetchDelegate = fetchDelegate
    }
    
    func fetch(completion: @escaping (Result<[Country], Error>) -> Void) {
        client.downloadData(from: url) { [weak self] result in
            switch result {
            case .success(let data):
                self?.parse(from: data, completion: completion)
                self?.fetchDelegate.didFetch(countries: self?.allCountries ?? [])
            case .failure(let error):
                completion(.failure(error))
                self?.fetchDelegate.failedToFetch(with: error)
            }
        }
    }
    
    private func parse(from data: Data, completion: @escaping (Result<[Country], Error>) -> Void) {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return completion(.failure(Error.jsonDecoding))
        }
        let countries = json.compactMap { country in
            mapCountry(country)
        }
        allCountries = countries

        completion(.success(countries))
    }
    
    private func mapCountry(_ country: [String: Any]) -> Country? {
        guard
            let name = country["name"] as? String,
            let alpha2Code = country["alpha2Code"] as? String,
            let region = country["region"] as? String,
            let subregion = country["subregion"] as? String,
            let capital = country["capital"] as? String,
            let population = country["population"] as? Int,
            let numericCode = country["numericCode"] as? String?,
            let coordinates = country["latlng"] as? [Float],
            let currenciesArray = country["currencies"] as? [[String: Any]]
        else { return nil }
        let currencies = currenciesArray.compactMap { currency in
            self.mapCurrency(currency)
        }
                
        return Country(
                        name: name,
                        flagURL: addImageURL(with: alpha2Code),
                        region: region,
                        subregion: subregion,
                        capital: capital,
                        population: population,
                        numericCode: numericCode,
                        coordinates: map(coordinates: coordinates),
                        currencies: currencies
                    )
    }
    
    private func addImageURL(with alpha2code: String) -> URL {
        let url = URL(string: "http://www.geonames.org/flags/x/"+alpha2code.lowercased()+".gif")!
        return url
    }

    private func mapCurrency(_ currency: [String: Any]) -> Currency? {
        guard
            let code = currency["code"] as? String,
            let symbol = currency["symbol"] as? String,
            let name = currency["name"] as? String
        else { return nil }

        return Currency(code: code, symbol: symbol, name: name, type: .fiat)
    }
    
    private func map(coordinates: [Float]) -> Coordinates {
        if coordinates.count != 2 {
            return Coordinates(latitude: 0,longitude: 0)
        }
        return Coordinates(latitude: coordinates[0], longitude: coordinates[1])
    }
}
