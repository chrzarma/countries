//
//  SceneDelegate.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 24/02/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, CountriesViewControllerSelectionDelegate, CountryDetailsMapSelectionDelegate, CountryDetailsExchangeBaseCurrencySelectionDelegate, CountriesFetchDelegate {
    
    var window: UIWindow?

    let navigationViewController = UINavigationController()
    private var allCurrencies = [Currency]()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let scene = (scene as? UIWindowScene) else { return }
        
        let client = HTTPClient()
        let fetcher = RemoteCountriesFetcher(client: client, fetchDelegate: self)
        let imageLoader = ImageLoader(client: client)
        let loader = Loader()
                
        let countriesViewController = CountriesViewController()
        
        countriesViewController.fetcher = RemoteAndSaveCountriesFetcher(remote: fetcher, cache: NSCountry.save(_:))
        countriesViewController.imageLoader = imageLoader
        countriesViewController.selectionDelegate = self
        countriesViewController.loader = loader
        
        navigationViewController.viewControllers = [countriesViewController]
        navigationViewController.navigationBar.barStyle = .black
        navigationViewController.navigationBar.tintColor = .white
        
        window = UIWindow(windowScene: scene)
        window?.rootViewController = navigationViewController
        window?.makeKeyAndVisible()
    }
    
    func didFetch(countries: [Country]) {
        let localCurrencies = countries.localCurrencies()
        allCurrencies = Array(Set(localCurrencies))
    }
    
    func failedToFetch(with error: Error) {
        allCurrencies = [Currency]()
    }
    
    func didSelect(country: Country, with image: UIImage?) {
        let countryDetailViewController = CountryDetailViewController()
        let client = HTTPClient()
        let capitalWOEIDFetcher = MetaWeatherWOEIDFetcher(client: client)
        let weatherFetcher = MetaWeatherCapitalCurrentWeatherFetcher(woeidFetcher: capitalWOEIDFetcher, client: client)
        let fiveDayForecastFetcher = MetaWeatherCapitalFiveDayForecastFetcher(woeidFetcher: capitalWOEIDFetcher, client: client)
        let exchangeRatesFetcher = ExchangeRatesApiFiatCurrencyExchangesFetcher(client: client, allCurrencies: allCurrencies)
        let loader = Loader()
        
        countryDetailViewController.country = country
        countryDetailViewController.flag = image
        countryDetailViewController.detailsMapSelectionDelegate = self
        countryDetailViewController.detailsExchangeBaseCurrencySelectionDelegate = self
        countryDetailViewController.weatherFetcher = weatherFetcher
        countryDetailViewController.fiveDayForecastFetcher = fiveDayForecastFetcher
        countryDetailViewController.usdExchangeRateFetcher = RemoteAndSaveDollarExchangeRateCurrencyExchangesFetcher(remote: exchangeRatesFetcher, cache: NSCurrencyExchange.saveDollarCurrencyExchange(_:forCurrency:))
        countryDetailViewController.loader = loader

                 
        navigationViewController.pushViewController(countryDetailViewController, animated: true)
    }
    
    func didSelectMapFor(countryName: String, coordinates: Coordinates) {
        let countryMapViewController = CountryMapViewController(country: countryName, coordinates: coordinates)
        
        navigationViewController.pushViewController(countryMapViewController, animated: true)
    }

    func didSelectExchangeBaseCurrency(for localCurrency: Currency) {
        let client = HTTPClient()
        let exchangeBaseCurrencyViewController = ExchangeBaseCurrencyViewController()
        let fiatCurrencyExchangesFetcher = ExchangeRatesApiFiatCurrencyExchangesFetcher(client: client, allCurrencies: allCurrencies)
        let cryptoCurrencyExchangesFetcher = CoinloreApiCryptoCurrencyExchangesFetcher( client: client,
                                                                    localToUsdFetcher: fiatCurrencyExchangesFetcher)
        let currencyExchangesFetcher = RemoteTimestampedCurrencyExchangesFetcher(client: client,
                                                                  fiatFetcher: fiatCurrencyExchangesFetcher,
                                                                  cryptoFetcher: cryptoCurrencyExchangesFetcher)
        let loader = Loader()


        exchangeBaseCurrencyViewController.localCurrency = localCurrency
        exchangeBaseCurrencyViewController.currencyExchangesFetcher = RemoteAndSaveTimestampedCurrencyExchangesFetcher(remote: currencyExchangesFetcher, cache: NSTimestampedCurrencyExchanges.save(_:forCurrency:))
        exchangeBaseCurrencyViewController.loader = loader

        navigationViewController.pushViewController(exchangeBaseCurrencyViewController, animated: true)
    }
}

extension Array where Element == Country {
    func localCurrencies() -> [Currency] {
        return compactMap { $0.currencies.first }
    }
}
