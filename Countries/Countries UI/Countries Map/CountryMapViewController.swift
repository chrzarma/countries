//
//  CountryMapViewController.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 28/02/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import UIKit
import MapKit

class CountryMapViewController: UIViewController {
    private var country: String!
    private var coordinates: Coordinates!
    
    convenience init(country: String, coordinates: Coordinates) {
        self.init()
        self.country = country
        self.coordinates = coordinates
    }
    
    private let regionRadius: CLLocationDistance = 2000000

    private let mapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let latitude = Double(coordinates!.latitude)
        let longitude = Double(coordinates!.longitude)
        
        let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        centerMapOnLocation(location: initialLocation)
        let countryPin = MKPointAnnotation()
        countryPin.title = country
        countryPin.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapView.addAnnotation(countryPin)
        
        setupMapView()
        self.title = "Map"
    }
    
    private func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
      mapView.setRegion(coordinateRegion, animated: true)
    }
    
    private func setupMapView() {
        self.view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mapView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            mapView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            mapView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            mapView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        ])
        
        mapView.isZoomEnabled = true
    }
}
