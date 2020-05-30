//
//  ImageLoader.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 25/02/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import UIKit

class ImageLoader {
    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImage(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        client.downloadData(from: url) { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure:
                completion(.failure(Error.invalidImageType))
            }
        }
    }
    
    func cancelableLoadImage(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> ImageDataLoaderTask {
        let urlSessionDataTask = client.cancelableDownloadData(from: url) { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure:
                completion(.failure(Error.invalidImageType))
            }
        }
        
        return ImageDataLoaderTask(urlSessionDataTask: urlSessionDataTask)
    }
}

class ImageDataLoaderTask: ImageLoaderTask {
    let urlSessionDataTask: URLSessionDataTask?
    
    init(urlSessionDataTask: URLSessionDataTask) {
        self.urlSessionDataTask = urlSessionDataTask
    }
    
    func cancel() {
        urlSessionDataTask?.cancel()
    }
}
