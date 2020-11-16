//
//  CountryDetailViewController.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 26/02/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import UIKit

protocol CountryDetailsMapSelectionDelegate {
    func didSelectMapFor(countryName: String, coordinates: Coordinates)
}

protocol CountryDetailsExchangeBaseCurrencySelectionDelegate {
    func didSelectExchangeBaseCurrency(for localCurrency: Currency)
}

class CountryDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var country: Country?
    var flag: UIImage?
    var loader: Loader?
    
    var detailsMapSelectionDelegate: CountryDetailsMapSelectionDelegate?
    var detailsExchangeBaseCurrencySelectionDelegate: CountryDetailsExchangeBaseCurrencySelectionDelegate?
    var weatherFetcher: CapitalCurrentWeatherFetcher?
    var fiveDayForecastFetcher: CapitalFiveDayForecastFetcher?
    var usdExchangeRateFetcher: CurrencyExchangesFetcher?
    
    private var exchangeRateAvailable = false
    var fiveDayForecast: [CapitalWeather]? {
        didSet {
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: 1, section: Section.weatherConditions.rawValue)
                self.tableView.reloadRows(at: [indexPath], with: .left)
            }
        }
    }
    
    private let toCurrency = Currency(code: "USD", symbol: "$", name: "United States dollar", type: .fiat)
    private var flagImageView = UIImageView()
    private var tableView = UITableView()
    
    var fiveDayForecastCell: FiveDayForecastCell?
    
    private lazy var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.roundingMode = .halfUp
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        return formatter
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    enum Section: Int {
        case countryDetails = 0
        case currency = 1
        case weatherConditions = 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
		setupUI(with: tableView, and: flagImageView, in: view)
        fetchCapitalFiveDayForecast()
    }
    
    private func fetchCapitalFiveDayForecast() {
        guard let capital = country?.capital else { return }
        
        fiveDayForecastFetcher?.fetch(capital) { [weak self] result in
            switch result {
            case .success(let fiveDayForecast):
                self?.fiveDayForecast = fiveDayForecast
            case .failure(let error):
                print(error)
            }
        }
    }
    	
	func numberOfSections(in tableView: UITableView) -> Int {
		3
	}

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == Section.currency.rawValue
            && indexPath.row == 2
            && exchangeRateAvailable == false {
            return 0
        }
        
        if indexPath.section == Section.currency.rawValue
            && indexPath.row == 0 {
            return 50
        }
        
        if indexPath.section == Section.weatherConditions.rawValue
            && indexPath.row == 1
            && (self.fiveDayForecast == nil) {
            return 0
        }
        
        if indexPath.section == Section.weatherConditions.rawValue
            && indexPath.row == 0 {
            return 55
        }
        
        if indexPath.section == Section.weatherConditions.rawValue
            && indexPath.row == 1
            && (self.fiveDayForecast != nil) {
            return 100
        }
        
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.countryDetails.rawValue: return 6
        case Section.currency.rawValue: return 3
        case Section.weatherConditions.rawValue: return 2
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case Section.countryDetails.rawValue: return "Country Details"
        case Section.currency.rawValue: return "Currency"
        case Section.weatherConditions.rawValue: return "Weather Conditions"
        default: return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == Section.countryDetails.rawValue {
            return setupCountryDetailsCells(at: indexPath)
        }
    
        if indexPath.section == Section.currency.rawValue {
            return setupCurrencyCells(at: indexPath)
        }
        
        if indexPath.section == Section.weatherConditions.rawValue {
            return setupWeatherConditionsCells(at: indexPath)
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == Section.countryDetails.rawValue && indexPath.row == 5, let country = country {
            detailsMapSelectionDelegate?.didSelectMapFor(countryName: country.name, coordinates: country.coordinates)
        }
        
        if indexPath.section == Section.currency.rawValue && indexPath.row == 2 && exchangeRateAvailable == true, let localCurrency = country?.currencies.first {
            detailsExchangeBaseCurrencySelectionDelegate?.didSelectExchangeBaseCurrency(for: localCurrency)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
//    MARK: Country Detail Section's Cells Setup

    
    private func setupCountryDetailsCells(at indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
            case 0:
                return countryDetailsCell(title: "Region",
                                          value: country?.region ?? "-",
                                          accessory: .none)
            case 1:
                return countryDetailsCell(title: "Subregion",
                                          value: country?.subregion ?? "-",
                                          accessory: .none)
            case 2:
                return countryDetailsCell(title: "Capital",
                                          value: country?.capital ?? "-",
                                          accessory: .none)
            case 3:
                let population = numberFormatter.string(from: NSNumber(value: country!.population))
                return countryDetailsCell(title: "Population",
                                          value: population ?? "-",
                                          accessory: .none)
            case 4:
                return countryDetailsCell(title: "Numeric Code",
                                          value: country?.numericCode ?? "-",
                                          accessory: .none)
            case 5:
                return countryDetailsCell(title: "Show In Map",
                                          value: "",
                                          accessory: .disclosureIndicator)
            default:
                return UITableViewCell()
        }
    }

    private func countryDetailsCell(title: String,
                                    value: String,
                                    accessory: UITableViewCell.AccessoryType ) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.textColor = .label
        cell.detailTextLabel?.textColor = .label
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = value
        cell.selectionStyle = .none
        cell.accessoryType = accessory
        return cell
    }
    
//    MARK: Currency Section's Cells Setup
    
    private func setupCurrencyCells(at indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard   let detailTitle = country?.currencies.first?.code,
                    let detailSubtitle = country?.currencies.first?.name
            else {  return currencyCell(title: "Local Currency",
                                        value: "N/A",
                                        accessory: .none)
            }
            return localCurrencyCell(title: "Local Currency",
                                     detailTitle: detailTitle,
                                     detailSubtitle: detailSubtitle,
                                     for: indexPath)
            
        case 1:
            return currencyExchangeCell(for: indexPath)
        case 2:
            return currencyCell(title: "More Exchange rates",
                                value: "",
                                accessory: .disclosureIndicator)
        default:
            return UITableViewCell()
        }
    }
    
    private func currencyCell(title: String,
                              value: String,
                              accessory: UITableViewCell.AccessoryType ) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.detailTextLabel?.textColor = .black
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = value
        cell.selectionStyle = .none
        cell.accessoryType = accessory

        return cell
    }
    
    private func localCurrencyCell(title: String,
                                   detailTitle: String,
                                   detailSubtitle: String,
                                   for indexPath: IndexPath) -> UITableViewCell {
        let localCurrencyCell = tableView.dequeueReusableCell(withIdentifier:
        "LocalCurrencyCell", for: indexPath) as! LocalCurrencyCell
        
        localCurrencyCell.titleLabel.text = title
        localCurrencyCell.detailTitleLabel.text = detailTitle
        localCurrencyCell.detailSubtitleLabel.text = detailSubtitle
        
        return localCurrencyCell
    }
    
    private func currencyExchangeCell(for indexPath: IndexPath) -> UITableViewCell {
        let exchangeRateCell = tableView.dequeueReusableCell(withIdentifier:
        "ExchangeRateCell", for: indexPath) as! ExchangeRateCell
        exchangeRateCell.textLabel?.text = "USD Exch. rate"
        exchangeRateCell.selectionStyle = .none
        
        if exchangeRateCell.detailTextLabel?.text?.isEmpty == true {
            exchangeRateCell.spinner.startAnimating()
            exchangeRateCell.accessoryView = exchangeRateCell.spinner
        }

        guard let currencies = country?.currencies, !currencies.isEmpty, let currency = currencies.first else {
            exchangeRateCell.detailTextLabel?.text = "N/A"
            exchangeRateCell.spinner.stopAnimating()
            exchangeRateCell.accessoryView = nil

            return exchangeRateCell
        }
        
        guard currency.code != toCurrency.code
        else {
            exchangeRateCell.detailTextLabel?.text = "1" + toCurrency.symbol
            exchangeRateCell.spinner.stopAnimating()
            exchangeRateCell.accessoryView = nil
            exchangeRateAvailable = true
            let indexPath = IndexPath(row: 2, section: Section.currency.rawValue)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
            return exchangeRateCell
        }

        usdExchangeRateFetcher?.fetch(for: currency) { [weak self] result in
            let exchangeRate: String
            switch result {
            case .success(let currencyExchanges):
                if let currencyExchange = currencyExchanges.first(where: {$0.to.code == self?.toCurrency.code }) {
                    let exchangeRateString = CustomCurrencyFormatter.input(String(currencyExchange.exchangeRate))
                    self?.exchangeRateAvailable = true
                    exchangeRate = "1 \(currencyExchange.from.code) \(currencyExchange.from.symbol) = " + (exchangeRateString ?? "") + " \(currencyExchange.to.code) \(currencyExchange.to.symbol)"
                } else {
                    exchangeRate = "N/A"
                }
            case .failure:
                if let currencyExchange = self?.loader?.loadDollarCurrencyExchange(for: currency) {
                    let exchangeRateString = CustomCurrencyFormatter.input(String(currencyExchange.exchangeRate))
                    self?.exchangeRateAvailable = true
                    exchangeRate = "1 \(currencyExchange.from.code) \(currencyExchange.from.symbol) = " + (exchangeRateString ?? "") + " \(currencyExchange.to.code) \(currencyExchange.to.symbol)"
                } else {
                    exchangeRate = "N/A"
                }
            }
            
            DispatchQueue.main.async {
                exchangeRateCell.spinner.stopAnimating()
                exchangeRateCell.accessoryView = nil
                exchangeRateCell.detailTextLabel?.text = exchangeRate
                let indexPath = IndexPath(row: 2, section: Section.currency.rawValue)
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }

        return exchangeRateCell
    }
    
//    MARK: Weather Section's Cells Setup
    
    private func setupWeatherConditionsCells(at indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return capitalCurrentWeatherCell(for: indexPath)
        case 1:
            let fiveDayForecastCell = tableView.dequeueReusableCell(withIdentifier:
            "FiveDayForecastCell", for: indexPath) as! FiveDayForecastCell
            self.fiveDayForecastCell = fiveDayForecastCell
            self.fiveDayForecastCell?.fiveDayForecast = self.fiveDayForecast
            return fiveDayForecastCell
        default:
            return UITableViewCell()
        }
    }
    
    private func capitalCurrentWeatherCell(for indexPath: IndexPath) -> UITableViewCell {
        let currentWeatherCell = tableView.dequeueReusableCell(withIdentifier:
        "CurrentWeatherCell", for: indexPath) as! CurrentWeatherCell
        currentWeatherCell.titleLabel.text = country?.capital
        currentWeatherCell.dateLabel.text = "Today"
        if currentWeatherCell.temperatureLabel.text == "Temperature" {
            currentWeatherCell.temperatureLabel.text = ""
        }
        
        if currentWeatherCell.temperatureLabel.text?.isEmpty == true {
            currentWeatherCell.spinner.startAnimating()
        }

        guard let capital = country?.capital else {
            currentWeatherCell.temperatureLabel.text = "N/A"
            currentWeatherCell.weatherImageView.image = UIImage()
            currentWeatherCell.spinner.stopAnimating()
            
            return currentWeatherCell
        }

        weatherFetcher?.fetch(capital) { result in
            let temperature: String
            let state: UIImage
            switch result {
            case .success(let weather):
                temperature = "\(Int(weather.minTemperature))/\(Int(weather.maxTemperature)) °C"
                state = UIImage(named: weather.state.imageName()) ?? UIImage()
            case .failure:
                temperature = "N/A"
                state = UIImage()
            }
            
            DispatchQueue.main.async {
                currentWeatherCell.temperatureLabel.text = temperature
                currentWeatherCell.weatherImageView.image = state
                currentWeatherCell.spinner.stopAnimating()
            }
        }
                    
        return currentWeatherCell
    }
    
//    MARK: Detail View's UI Setup
    
    private func setupUI(with tableView: UITableView, and flagImageView: UIImageView, in view: UIView) {
        setup(flagImageView: flagImageView, in: view)
        setup(tableView: tableView, with: flagImageView, in: view)
        
        title = country?.name
        flagImageView.image = flag
    }
    
    private func setup(tableView: UITableView,with upperView: UIView, in view: UIView) {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: upperView.bottomAnchor, constant: 5)
        ])
        
        let currentWeatherCell = UINib(nibName: "CurrentWeatherCell", bundle: nil)
        tableView.register(currentWeatherCell, forCellReuseIdentifier: "CurrentWeatherCell")
        
        let fiveDayForecastCell = UINib(nibName: "FiveDayForecastCell", bundle: nil)
        tableView.register(fiveDayForecastCell, forCellReuseIdentifier: "FiveDayForecastCell")
        
        let exchangeRateCell = UINib(nibName: "ExchangeRateCell", bundle: nil)
        tableView.register(exchangeRateCell, forCellReuseIdentifier: "ExchangeRateCell")
        
        let localCurrencyCell = UINib(nibName: "LocalCurrencyCell", bundle: nil)
        tableView.register(localCurrencyCell, forCellReuseIdentifier: "LocalCurrencyCell")
        
        tableView.tableFooterView = UIView()
        tableView.isScrollEnabled = true
        tableView.delegate = self
        tableView.dataSource = self
        
        view.backgroundColor = .black
    }
    
    private func setup(flagImageView: UIImageView, in view: UIView) {
        view.addSubview(flagImageView)
        flagImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            flagImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            flagImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            flagImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            flagImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3)
        ])
        
        flagImageView.contentMode = .scaleAspectFit
    }
}
