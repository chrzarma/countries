//
//  HTTPClient.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 24/02/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import Foundation
import Network

final class HTTPClient {
    func downloadData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, _ , error) in
            if let data = data {
                completion(.success(data))
            } else {
                    completion(.failure(Error.invalidData))
            }
        }.resume()
    }
    
    func cancelableDownloadData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { (data, _ , error) in
            if let data = data {
                completion(.success(data))
            } else {
                    completion(.failure(Error.invalidData))
            }
        }
        task.resume()
        
        return task
    }
}
