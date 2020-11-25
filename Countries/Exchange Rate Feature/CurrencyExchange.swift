//
//  CurrencyExchange.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 20/03/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import Foundation
import os.log

struct CurrencyExchange {
    let from: Currency
    let to: Currency
    let exchangeRate: Double
}

class NSCurrencyExchange: NSObject, NSCoding {
    var currencyExchange: CurrencyExchange
    
    init(currencyExchange: CurrencyExchange) {
        self.currencyExchange = currencyExchange
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let from = aDecoder.decodeObject(forKey: "from") as? NSCurrency,
            let to = aDecoder.decodeObject(forKey: "to") as? NSCurrency else { return nil }

        let exchangeRate = aDecoder.decodeDouble(forKey: "exchangeRate")
        
        currencyExchange = CurrencyExchange(from: from.currency, to: to.currency, exchangeRate: exchangeRate)
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(NSCurrency(currency: currencyExchange.from), forKey: "from")
        aCoder.encode(NSCurrency(currency: currencyExchange.to), forKey: "to")
        aCoder.encode(currencyExchange.exchangeRate, forKey: "exchangeRate")
    }
    
    // MARK: Archiving Paths
        
    static func saveDollarCurrencyExchange(_ dollarCurrencyExchange: CurrencyExchange, forCurrency: Currency) {
        let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("\(forCurrency.code).dollarCurrencyExchange")
        let currencyExchange = NSCurrencyExchange(currencyExchange: dollarCurrencyExchange)

        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: currencyExchange, requiringSecureCoding: false)
            try data.write(to: archiveURL)
            os_log("DollarCurrencyExchange successfully saved.", log: OSLog.default, type: .debug)
        } catch {
            os_log("Failed to save dollarCurrencyExchange...", log: OSLog.default, type: .error)
        }
    }

    static func loadDollarCurrencyExchange(forCurrency: Currency) -> CurrencyExchange? {
        let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("\(forCurrency.code).dollarCurrencyExchange")
        if let nsData = NSData(contentsOf: archiveURL) {
            do {
                let data = Data(referencing:nsData)
                os_log("DollarCurrencyExchange loaded", log: OSLog.default, type: .debug)
                if let loadedDollarCurrencyExchange = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? NSCurrencyExchange {
                    let dollarCurrencyExchange = loadedDollarCurrencyExchange.currencyExchange
                    return dollarCurrencyExchange
                }
            } catch {
                os_log("Couldn't read file", log: OSLog.default, type: .error)
                return nil
            }
        }
        return nil
    }
}
