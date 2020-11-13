//
//  CountriesViewController.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 24/02/2020
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import UIKit

protocol ImageLoaderTask {
    func cancel()
}

protocol CountriesViewControllerSelectionDelegate {
    func didSelect(country: Country, with: UIImage?)
}

class CountriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITableViewDataSourcePrefetching {
    
    var fetcher: CountriesFetcher?
    var imageLoader: ImageLoader?
    var selectionDelegate: CountriesViewControllerSelectionDelegate?
    var loader: Loader?
    
    private var searchBar = UISearchBar()
    private var resultsHeader = UILabel()
    private var errorHeader = UILabel()
    private var informationContainerView = UIView()
    private var tableView = UITableView()
    
    private var countries = [Country]()
    private var filteredCountries = [Country]()
    private var countryFlags = [Country : UIImage]()
    private var regions =   [ Region(countries: [Country](), name: "Africa"),
                              Region(countries: [Country](), name: "Americas"),
                              Region(countries: [Country](), name: "Asia"),
                              Region(countries: [Country](), name: "Europe"),
                              Region(countries: [Country](), name: "Oceania")
                            ]
    private var tasks = [IndexPath: ImageLoaderTask]()
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")

        fetcher?.fetch { [weak self] result in
            switch result {
            case .success(let countries):
                self?.countries = countries
                self?.filteredCountries = countries
                self?.fillRegionsArrays()
            case .failure:
                guard let loadedCountries = self?.loader?.loadCountries() else {
                    DispatchQueue.main.async {
                        self?.handleFetchFailure()
                    }
                    return
                }
                self?.countries = loadedCountries
                self?.emptyRegionArrays()
                self?.filteredCountries = loadedCountries
                self?.fillRegionsArrays()
            }

            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        let nibName = UINib(nibName: "CountryCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "CountryCell")

        self.title = "Countries"
        
        setup(searchBar: searchBar, in: self.view)
        setup(informationContainerView: informationContainerView, in: self.view)
        setup(resultsHeader: resultsHeader, in: informationContainerView)
        setup(tableView: tableView, in: self.view)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return regions.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if regions[section].countries.isEmpty {
            return nil
        }
        
        return regions[section].name
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regions[section].countries.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath) as! CountryCell
        cell.selectionStyle = .none

        let country = regions[indexPath.section].countries[indexPath.row]

        cell.add(countryName: country.name)
        cell.add(flag: UIImage.make(withColor: .gray))
        cell.flagView.startShimmering()

        guard let image = countryFlags[country] else {
            tasks[indexPath] = self.imageLoader?.cancelableLoadImage(from: country.flagURL) { [weak self] result in
                switch result {
                case .success(let data):
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.countryFlags[country] = image
                            cell.add(flag: image)
                            cell.flagView.stopShimmering()
                        }
                    }
                case .failure: break
                }
            }
            return cell
        }
        cell.add(flag: image)
        cell.flagView.stopShimmering()

        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country: Country

        country = regions[indexPath.section].countries[indexPath.row]
        
        let flag = countryFlags[country]
        
        selectionDelegate?.didSelect(country: country, with: flag)
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let country: Country
            country = regions[indexPath.section].countries[indexPath.row]
            guard let _ = countryFlags[country] else {
                tasks[indexPath] = self.imageLoader?.cancelableLoadImage(from: country.flagURL) { [weak self] result in
                    switch result {
                    case .success(let data):
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self?.countryFlags[country] = image
                            }
                        }
                    case .failure:  break
                    }
                }
                return
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            tasks[indexPath]?.cancel()
            tasks[indexPath] = nil
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            resetTableView()
        } else {
            tableView.refreshControl = nil
            emptyRegionArrays()
            filteredCountries = countries.filter({ (country: Country) -> Bool in
                return country.name.lowercased().hasPrefix(searchText.lowercased())
            })
            fillRegionsArrays()
            resultsHeader.text = "\(filteredCountries.count) out of \(countries.count)"
        }
        
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        resetTableView()
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
//  MARK: Helpers
    
    private func fillRegionsArrays() {
        self.filteredCountries.forEach { country in
            if country.region == regions[0].name {
                regions[0].countries.append(country)
            } else if country.region == regions[1].name {
                regions[1].countries.append(country)
            } else if country.region == regions[2].name {
                regions[2].countries.append(country)
            } else if country.region == regions[3].name {
                regions[3].countries.append(country)
            } else if country.region == regions[4].name {
                regions[4].countries.append(country)
            }
        }
    }
    
    private func emptyRegionArrays() {
        for i in 0...(regions.count - 1) {
            regions[i].countries = [Country]()
        }
    }
    
    private func resetTableView() {
        emptyRegionArrays()
        filteredCountries = countries
        fillRegionsArrays()
        resultsHeader.text = ""
        tableView.refreshControl = refreshControl
    }
    
    @objc func handleRefresh() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] (timer) in
            self?.fetcher?.fetch { [weak self] result in
                switch result {
                case .success(let countries):
                    self?.countries = countries
                    self?.emptyRegionArrays()
                    self?.filteredCountries = countries
                    self?.fillRegionsArrays()
                case .failure:
                    guard let loadedCountries = self?.loader?.loadCountries() else {
                        DispatchQueue.main.async {
                            self?.handleFetchFailure()
                            self?.refreshControl.endRefreshing()
                        }
                        return
                    }
                    self?.countries = loadedCountries
                    self?.emptyRegionArrays()
                    self?.filteredCountries = loadedCountries
                    self?.fillRegionsArrays()
                }

                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    private func handleFetchFailure() {
        let alert = UIAlertController(title: "Connection Error", message: "There seems to be a connection problem. Please try again later!", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel)
        alert.addAction(action)
        
        present(alert, animated: true)
    }

// MARK: UIHelpers
    
    private func setup(searchBar: UISearchBar, in view: UIView) {
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        searchBar.delegate = self
        searchBar.placeholder = "Search Countries"
        searchBar.barTintColor = .black
        searchBar.searchTextField.backgroundColor = .secondarySystemBackground
    }
    
    private func setup(tableView: UITableView, in view: UIView) {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: resultsHeader.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        tableView.prefetchDataSource = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
    }
    
    private func setup(informationContainerView: UIView, in view: UIView) {
        view.addSubview(informationContainerView)
        informationContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            informationContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            informationContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            informationContainerView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            informationContainerView.heightAnchor.constraint(equalToConstant: 30)
        ])

        resultsHeader.textColor = .white
        resultsHeader.textAlignment = .center
    }

    private func setup(resultsHeader: UILabel, in informationContainerView: UIView) {
        view.addSubview(resultsHeader)
        resultsHeader.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            resultsHeader.trailingAnchor.constraint(equalTo: informationContainerView.trailingAnchor),
            resultsHeader.leadingAnchor.constraint(equalTo: informationContainerView.leadingAnchor),
            resultsHeader.topAnchor.constraint(equalTo: informationContainerView.topAnchor),
            resultsHeader.bottomAnchor.constraint(equalTo: informationContainerView.bottomAnchor)
        ])

        resultsHeader.textColor = .white
        resultsHeader.textAlignment = .center
        resultsHeader.alpha = 1
    }
}
