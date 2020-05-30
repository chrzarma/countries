//
//  WeatherState.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 15/03/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import Foundation

enum WeatherState {
    case snow, sleet, hail, thunderstorm, heavyRain, lightRain, showers, heavyCloud, lightCloud, clear, unknown
    
    func imageName() -> String {
        switch self {
        case .snow: return "sn"
        case .sleet: return "sl"
        case .hail: return "h"
        case .thunderstorm: return "t"
        case .heavyRain: return "hr"
        case .lightRain: return "lr"
        case .showers: return "s"
        case .heavyCloud: return "hc"
        case .lightCloud: return "lc"
        case .clear: return "c"
        case .unknown: return ""
        }
    }
}
