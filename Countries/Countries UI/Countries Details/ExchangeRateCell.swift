//
//  ExchangeRateCell.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 20/03/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import UIKit

class ExchangeRateCell: UITableViewCell {
    let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()
}
