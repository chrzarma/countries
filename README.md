

## Summary

Countries is an iOS client project that uses the following APIs to search and download information about countries:

- https://restcountries.eu (for countries information)
- https://www.metaweather.com/api/ (for weather information)
- https://exchangeratesapi.io (for foreign exchange rates)
- https://www.coinlore.com/cryptocurrency-data-api (for crypto exchange rates)

This project has been written in Swift 5.0 and runs on any iPhone or iPad with iOS 13.0 and above.

## Features

App Features

- Shows a list of all countries with their flags, grouped by region.
- Shows information about the selected country.
- Shows selected country in map.
- Shows capital's today's weather, when available.
- Shows capital's five day forecast, when available.
- Shows the exchange rate of the local currency to USD.
- Shows the exchange rate of the local currency to other currencies and to cryptocurrencies.

## App Screenshots

![countries](https://github.com/chrzarma/countries/blob/master/LightTheme.png)
![countries](https://github.com/chrzarma/countries/blob/master/DarkTheme.png)

## Features Breakdown

- Why does the app have to cache the data? 

If the device has an active and available network then the user will get access to any of the data he wants to see. But if the network is inactive or not available, I thought that it would be more appropriate and useful to show to the User the last data he received and inform him about the validation of time-sensitive data received (for example the date of the exchange rates).

- What happens when the cache is empty and there is no available network?

Then the app informs the user that there is no valid connection and that he should try again after establishing a valid connection.

- What happens if you want to replace any of the APIs you use to retrieve data?

By using protocol implementations as boundaries between the network module and the main module (in order to depend on abstractions), we have the flexibility to change the API we use to retrieve the data by only making the new API to conform to the protocol we have implemented
