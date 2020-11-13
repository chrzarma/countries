//
//  ExchangeBaseCurrencyViewController.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 25/03/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import UIKit

class ExchangeBaseCurrencyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var localCurrency: Currency?
    var currencyExchangesFetcher: TimestampedCurrencyExchangesFetcher?
    var loader: Loader?

    private enum Segment: Int {
        case fiat = 0
        case crypto = 1
    }
    
    private enum Fetching {
        case isActive, isInactive
    }
    
    private enum LocalCurrencyStatus {
        case base, toCurrency
    }

    private let tableView = UITableView()
    private let lastUpdatedLabel = UILabel()
    private var lastUpdatedFiatString = String()
    private var lastUpdatedCryptoString = String()
    private var fiatCurrencyExchanges = [CurrencyExchange]()
    private var cryptoCurrencyExchanges = [CurrencyExchange]()
    private let segmentedControl = UISegmentedControl(items: ["Countries Currencies", "Cryptos"])
    private var segmentCurrencyExchanges = [CurrencyExchange]()
    private var refreshBarButton: UIBarButtonItem!
    private let refreshSpinner: UIActivityIndicatorView = {
        let refreshSpinner = UIActivityIndicatorView()
        refreshSpinner.style = .medium
        refreshSpinner.color = .white
        refreshSpinner.hidesWhenStopped = true
        return refreshSpinner
    }()
    
    private var fetching = Fetching.isInactive {
        didSet {
            switch fetching {
            case .isActive: showRefreshSpinner()
            case .isInactive: showRefreshButton()
            }
        }
    }
    private var localCurrencyStatus = LocalCurrencyStatus.base
    
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
        formatter.dateFormat = "dd-MM-yyyy, HH:mm"
        formatter.locale = Locale.current
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView(for: segmentedControl, with: lastUpdatedLabel, and: tableView, in: view)
        fetchCurrencyExchanges()
    }

   func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        segmentCurrencyExchanges.count
    }
    
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return setupCurrencyCell(for: indexPath, currencyExchanges: segmentCurrencyExchanges)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        reverseExchangeRates()
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }

    @objc func refreshTableview() {
        fetchCurrencyExchanges()
    }
    
    @objc func handleSegmentChange() {
        switch segmentedControl.selectedSegmentIndex {
        case Segment.fiat.rawValue:
            segmentCurrencyExchanges = fiatCurrencyExchanges
            lastUpdatedLabel.text = lastUpdatedFiatString
        case Segment.crypto.rawValue:
            segmentCurrencyExchanges = cryptoCurrencyExchanges
            lastUpdatedLabel.text = lastUpdatedCryptoString
        default :
            segmentCurrencyExchanges = fiatCurrencyExchanges
        }
        tableView.reloadData()
    }
        
//  MARK: Helpers
    
    private func fetchCurrencyExchanges() {
        guard let localCurrency = self.localCurrency else { return }
        fetching = .isActive
        tableView.reloadData()
        currencyExchangesFetcher?.fetchTimestamped(for: localCurrency) { [weak self] result in
            switch result {
            case .success(let timestampedCurrencyExchanges):
                self?.fiatCurrencyExchanges = timestampedCurrencyExchanges.currencyExchanges.filter { $0.to.type == .fiat }
                self?.cryptoCurrencyExchanges  = timestampedCurrencyExchanges.currencyExchanges.filter { $0.to.type == .crypto }
                if timestampedCurrencyExchanges.timestamps.count == 2 {
                    self?.refreshLastUpdatedLabel(for: timestampedCurrencyExchanges)
                }
                
                if self?.localCurrencyStatus == .toCurrency {
                    DispatchQueue.main.async {
                        self?.mapAllCurrencyExchanges()
                    }
                }
            case .failure:
                if let loadedTimestampedCurrencyExchanges = self?.loader?.loadTimestampedCurrencyExchanges(for: localCurrency) {
                    self?.fiatCurrencyExchanges = loadedTimestampedCurrencyExchanges.currencyExchanges.filter { $0.to.type == .fiat }
                    self?.cryptoCurrencyExchanges  = loadedTimestampedCurrencyExchanges.currencyExchanges.filter { $0.to.type == .crypto }
                    self?.refreshLastUpdatedLabel(for: loadedTimestampedCurrencyExchanges)
                } else {
                    DispatchQueue.main.async {
                        self?.handleFetchFailure()
                        self?.lastUpdatedLabel.text = nil
                    }
                }
            }
            
            DispatchQueue.main.async {
                self?.resetExchangeRates()
            }
        }
    }
    
    private func resetExchangeRates() {
        fetching = .isInactive
        handleSegmentChange()
        tableView.reloadData()
    }
    
    private func refreshLastUpdatedLabel(for timestampedCurrencyExchanges: TimestampedCurrencyExchanges) {
        let fiatTimeStamp = timestampedCurrencyExchanges.timestamps.filter { $0.currencyType == .fiat }.first
        let cryptoTimeStamp = timestampedCurrencyExchanges.timestamps.filter { $0.currencyType == .crypto }.first
        
        guard let fiatDate = fiatTimeStamp?.date, let cryptoDate = cryptoTimeStamp?.date else { return }
        lastUpdatedFiatString = "Last updated: " + dateFormatter.string(from: fiatDate)
        lastUpdatedCryptoString = "Last updated: " + dateFormatter.string(from: cryptoDate)
    }
    
    private func reverseExchangeRates() {
        switch localCurrencyStatus {
        case .base:
            mapAllCurrencyExchanges()
            localCurrencyStatus = .toCurrency
        case .toCurrency:
            mapAllCurrencyExchanges()
            localCurrencyStatus = .base
        }
    }
    
    private func mapAllCurrencyExchanges() {
        segmentCurrencyExchanges = map(segmentCurrencyExchanges)
        fiatCurrencyExchanges = map(fiatCurrencyExchanges)
        cryptoCurrencyExchanges = map(cryptoCurrencyExchanges)
    }
    
    private func map(_ currencyExchanges: [CurrencyExchange]) -> [CurrencyExchange]{
        var mappedExchangeRates = [CurrencyExchange]()
        currencyExchanges.forEach { exchangeRate in
            let decimalExchangeRate = 1/Decimal(floatLiteral: exchangeRate.exchangeRate)
            let doubleExchangeRate = (decimalExchangeRate as NSDecimalNumber).doubleValue
            mappedExchangeRates.append(CurrencyExchange(from: exchangeRate.to, to: exchangeRate.from, exchangeRate: doubleExchangeRate))
        }
        
        return mappedExchangeRates
    }
    
//    MARK: UI Helpers
    
    private func setupCurrencyCell(for  indexPath: IndexPath, currencyExchanges: [CurrencyExchange]) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExchangeCurrencyCell", for: indexPath) as! ExchangeCurrencyCell
        cell.selectionStyle = .none
        
        let toCurrency = currencyExchanges[indexPath.row].to
        let baseCurrency = currencyExchanges[indexPath.row].from
        
        switch localCurrencyStatus {
        case .base:
            cell.titleLabel.text = toCurrency.code
            cell.subtitleLabel.text = toCurrency.name
            cell.currencyIconView.image = UIImage(named: toCurrency.code)
        case .toCurrency:
            cell.titleLabel.text = baseCurrency.code
            cell.subtitleLabel.text = baseCurrency.name
            cell.currencyIconView.image = UIImage(named: baseCurrency.code)
        }

        let currencyExchangeRate = currencyExchanges[indexPath.row].exchangeRate
        
        if fetching == .isActive {
            cell.detailLabel?.text = ""
            cell.spinner.startAnimating()
        } else {
            guard let currencyExchangeString = numberFormatter.string(from: NSNumber(value: currencyExchangeRate)) else {
                cell.spinner.stopAnimating()
                cell.detailLabel?.text = "N/A"
                return cell
            }
            cell.spinner.stopAnimating()
            cell.detailLabel?.text =    "1 " + baseCurrency.symbol + " = " +
                                        currencyExchangeString + " " + toCurrency.symbol
        }
        
        return cell
    }
    
    private func setupView(for segmentedControlView: UISegmentedControl,with lastUpdatedView: UILabel, and tableView: UITableView, in view: UIView) {
        let paddedStackView = UIStackView(arrangedSubviews: [segmentedControlView])
        paddedStackView.layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)
        paddedStackView.isLayoutMarginsRelativeArrangement = true
               
        let stackView = UIStackView(arrangedSubviews: [paddedStackView, lastUpdatedView, tableView])
        stackView.axis = .vertical
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            lastUpdatedView.heightAnchor.constraint(equalToConstant: 22)
        ])
        
        segmentedControl.backgroundColor = .gray
        segmentedControl.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        
        lastUpdatedLabel.backgroundColor = .darkGray
        lastUpdatedLabel.textColor = .white
        lastUpdatedLabel.textAlignment = .center
        lastUpdatedLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.footnote)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        let nibName = UINib(nibName: "ExchangeCurrencyCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "ExchangeCurrencyCell")
        
        title = "Exchange Rates"
        refreshBarButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshTableview))
        navigationItem.rightBarButtonItem = refreshBarButton
        navigationController?.navigationBar.isTranslucent = false
        view.backgroundColor = .black
    }
    
    private func showRefreshSpinner() {
        let refreshSpinnerBarButton = UIBarButtonItem.init(customView: refreshSpinner)
        refreshSpinner.startAnimating()
        navigationItem.setRightBarButton(refreshSpinnerBarButton, animated: true)
    }
    
    private func showRefreshButton() {
        refreshSpinner.stopAnimating()
        navigationItem.setRightBarButton(self.refreshBarButton, animated: true)
    }
    
    private func handleFetchFailure() {
        let alert = UIAlertController(title: "Connection Error", message: "There seems to be a connection problem. Please try again later!", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        alert.addAction(action)
        
        present(alert, animated: true)
    }
}
