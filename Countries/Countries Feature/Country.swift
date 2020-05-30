//
//  Country.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 24/02/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import Foundation
import os.log

struct Country: Hashable {
    let name: String
    let flagURL: URL
    let region: String
    let subregion: String
    let capital: String
    let population: Int
    let numericCode: String?
    let coordinates: Coordinates
    let currencies: [Currency]
}

class NSCountry: NSObject, NSCoding {
    var country: Country
    
    init(country: Country) {
        self.country = country
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: "name") as? String,
            let flagURLString = aDecoder.decodeObject(forKey: "flagURL") as? String,
            let region = aDecoder.decodeObject(forKey: "region") as? String,
            let subregion = aDecoder.decodeObject(forKey: "subregion") as? String,
            let capital = aDecoder.decodeObject(forKey: "capital") as? String,
            let numericCode = aDecoder.decodeObject(forKey: "numericCode") as? String?,
            let currencies = aDecoder.decodeObject(forKey: "currencies") as? [NSCurrency],
            let flagURL = URL(string: flagURLString) else { return nil }
        
        let population = aDecoder.decodeInteger(forKey: "population")
        let latitude = aDecoder.decodeFloat(forKey: "latitude")
        let longitude = aDecoder.decodeFloat(forKey: "longitude")

        country = Country(name: name, flagURL: flagURL, region: region, subregion: subregion, capital: capital, population: population, numericCode: numericCode, coordinates: Coordinates(latitude: latitude, longitude: longitude), currencies: currencies.map{$0.currency})
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(country.name, forKey: "name")
        aCoder.encode(country.flagURL.absoluteString, forKey: "flagURL")
        aCoder.encode(country.region, forKey: "region")
        aCoder.encode(country.subregion, forKey: "subregion")
        aCoder.encode(country.currencies.map{NSCurrency(currency: $0)}, forKey: "currencies")
        aCoder.encode(country.capital, forKey: "capital")
        aCoder.encode(country.population, forKey: "population")
        aCoder.encode(country.numericCode, forKey: "numericCode")
        aCoder.encode(country.coordinates.latitude, forKey: "latitude")
        aCoder.encode(country.coordinates.longitude, forKey: "longitude")
    }
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("countries")
    
    static func save(_ countriesArray: [Country]) {
        let countries = countriesArray.map{ NSCountry(country: $0) }

        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: countries, requiringSecureCoding: false)
            try data.write(to: NSCountry.ArchiveURL)
            os_log("Countries successfully saved.", log: OSLog.default, type: .debug)
        } catch {
            os_log("Failed to save countries...", log: OSLog.default, type: .error)
        }
    }

    static func loadCountries() -> [Country]? {
        if let nsData = NSData(contentsOf: NSCountry.ArchiveURL) {
            do {
                let data = Data(referencing: nsData)
                os_log("Countries loaded", log: OSLog.default, type: .debug)
                if let loadedCountries = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [NSCountry] {
                    let countries = loadedCountries.map{ $0.country }
                    return countries
                }
            } catch {
                os_log("Couldn't read file", log: OSLog.default, type: .error)
                return nil
            }
        }
        return nil
    }
}

