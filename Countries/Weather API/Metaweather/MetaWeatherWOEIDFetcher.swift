//
//  MetaWeatherWOEIDFetcher.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 15/03/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import Foundation

class MetaWeatherWOEIDFetcher {
    struct WOEID {
        let value: Int
    }
    
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func fetch(_ capital: String, completion: @escaping (Result<WOEID, Error>) -> Void) {
        guard let url = MetaWeatherWOEIDFetcher.url(for: capital) else {
            return completion(.failure(Error.invalidURL))
        }
        
        client.downloadData(from: url) { result in
            switch result {
            case .success(let data):
                if let woeid = MetaWeatherWOEIDFetcher.map(data) {
                    completion(.success(woeid))
                } else {
                    completion(.failure(Error.invalidData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private static func url(for capital: String) -> URL? {
        var components = URLComponents(string: "https://www.metaweather.com/api/location/search")
        components?.queryItems = [URLQueryItem(name: "query", value: capital)]
        return components?.url
    }
    
    private static func map(_ data: Data) -> WOEID? {
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
            let object = json.first,
            let woeid = object["woeid"] as? Int
        else { return nil }
                            
        return MetaWeatherWOEIDFetcher.WOEID(value: woeid)
    }

}
