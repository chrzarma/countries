//
//  CurrentWeatherCell.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 15/03/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import UIKit

class CurrentWeatherCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var weatherImageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var spinner: UIActivityIndicatorView!
}
