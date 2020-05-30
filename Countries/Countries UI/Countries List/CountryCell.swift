//
//  CountryCell.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 04/03/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import UIKit

class CountryCell: UITableViewCell {
    @IBOutlet var countryName: UILabel!
    @IBOutlet var flagView: UIImageView!
    
    func add(countryName: String) {
        self.countryName.text = countryName
    }
    
    func add(flag: UIImage) {
        self.flagView.image = flag
    }
}
