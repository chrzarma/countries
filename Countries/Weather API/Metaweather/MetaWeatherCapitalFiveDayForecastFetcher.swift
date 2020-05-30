//
//  MetaWeatherCapitalFiveDayForecast.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 17/03/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import Foundation

class MetaWeatherCapitalFiveDayForecastFetcher: CapitalFiveDayForecastFetcher {
    private let woeidFetcher: MetaWeatherWOEIDFetcher
    private let client: HTTPClient
    
    init(woeidFetcher: MetaWeatherWOEIDFetcher, client: HTTPClient) {
        self.woeidFetcher = woeidFetcher
        self.client = client
    }
     
    func fetch(_ capital: String, completion: @escaping (Result<[CapitalWeather], Error>) -> Void) {
        woeidFetcher.fetch(capital) { [weak self] result in
            switch result {
            case .success(let woeid):
                guard let url = MetaWeatherCapitalFiveDayForecastFetcher.url(for: "\(woeid.value)") else {
                    return completion(.failure(Error.invalidURL))
                }
                
                self?.client.downloadData(from: url) { result in
                    switch result {
                    case .success(let data):
                        if let weather = MetaWeatherCapitalFiveDayForecastFetcher.map(data) {
                            completion(.success(weather))
                        } else {
                            completion(.failure(Error.invalidData))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private static func url(for token: String) -> URL? {
        return URL(string: "https://www.metaweather.com/api/location/\(token)")
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private static func map(_ data: Data) -> [CapitalWeather]? {
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let consolidatedWeather = json["consolidated_weather"] as? [[String: Any]],
            let _ = consolidatedWeather.first
        else { return nil }
        
        return Array(consolidatedWeather.dropFirst()).compactMap { dictionary in
            return MetaWeatherCapitalFiveDayForecastFetcher.map(dictionary)
        }
    }
    
    private static func map(_ dictionary: [String: Any]) -> CapitalWeather? {
        guard
            let maxTemp = dictionary["max_temp"] as? Double,
            let minTemp = dictionary["min_temp"] as? Double,
            let dateString = dictionary["applicable_date"] as? String,
            let formattedDate = dateFormatter.date(from: dateString),
            let stateString = dictionary["weather_state_abbr"] as? String
        else { return nil }
        
        return CapitalWeather(maxTemperature: maxTemp, minTemperature: minTemp, date: formattedDate, state: WeatherState.state(from: stateString))
    }
}
