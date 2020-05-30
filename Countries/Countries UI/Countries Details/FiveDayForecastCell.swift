//
//  FiveDayForecastCell.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 17/03/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import UIKit

class FiveDayForecastCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    
    let numberOfItemsPerRow: CGFloat = 5
    let spacingBetweenCells: CGFloat = 10
    
    var fiveDayForecast: [CapitalWeather]? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private lazy var dateFormatter: DateFormatter = {
           let formatter = DateFormatter()
           formatter.dateFormat = "MMM d"
           return formatter
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "FiveDayWeatherForecastCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FiveDayWeatherForecastCollectionViewCell")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing = (numberOfItemsPerRow - 1) * spacingBetweenCells

        if let collection = self.collectionView{
             let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
             let height = collection.bounds.height
             return CGSize(width: width, height: height)
        } else {
            return CGSize(width: 0, height: 0)
        }
     }

     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
         return spacingBetweenCells
     }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let fiveDayForecast = self.fiveDayForecast else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FiveDayWeatherForecastCollectionViewCell", for: indexPath) as! FiveDayWeatherForecastCollectionViewCell
        let date = fiveDayForecast[indexPath.row].date
        let state = fiveDayForecast[indexPath.row].state
        let minTemp = fiveDayForecast[indexPath.row].minTemperature
        let maxTemp = fiveDayForecast[indexPath.row].maxTemperature
        let dateString = dateFormatter.string(from: date)
        let stateString = state.imageName()

        cell.dateLabel.text = dateString
        cell.weatherImageView.image = UIImage(named: stateString)
        cell.temperatureLabel.text = "\(Int(minTemp))/\(Int(maxTemp)) °C"
        
        return cell
    }
}
