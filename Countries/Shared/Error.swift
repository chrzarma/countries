//
//  Error.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 25/05/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import Foundation

enum Error: Swift.Error {
    case invalidData
    case invalidURL
    case invalidImageType
    case jsonDecoding
}
