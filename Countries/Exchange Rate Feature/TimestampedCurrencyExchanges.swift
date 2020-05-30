//
//  TimestampedCurrencyExchanges.swift
//  Countries
//
//  Created by Christian Zarmakoupis on 09/04/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import Foundation
import os.log

struct Timestamp {
    let currencyType: CurrencyType
    let date: Date
}

class NSTimestamp: NSObject, NSCoding {
    var timestamp: Timestamp
    
    init(timestamp: Timestamp) {
        self.timestamp = timestamp
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let currencyType = aDecoder.decodeObject(forKey: "currencyType") as? String,
            let date = aDecoder.decodeObject(forKey: "date") as? Date else { return nil }
        
        timestamp = Timestamp(currencyType: CurrencyType.create(from: currencyType), date: date)
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(CurrencyType.getString(from: timestamp.currencyType), forKey: "currencyType")
        aCoder.encode(timestamp.date, forKey: "date")
    }
}


struct TimestampedCurrencyExchanges {
    let currencyExchanges: [CurrencyExchange]
    let timestamps: [Timestamp]
}

class NSTimestampedCurrencyExchanges: NSObject, NSCoding {
    var timestampedCurrencyExchanges: TimestampedCurrencyExchanges
    
    init(timestampedCurrencyExchanges: TimestampedCurrencyExchanges) {
        self.timestampedCurrencyExchanges = timestampedCurrencyExchanges
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let currencyExchanges = aDecoder.decodeObject(forKey: "currencyExchanges") as? [NSCurrencyExchange],
            let timestamps = aDecoder.decodeObject(forKey: "timestamps") as? [NSTimestamp] else { return nil }

        timestampedCurrencyExchanges = TimestampedCurrencyExchanges(currencyExchanges: currencyExchanges.map({$0.currencyExchange}), timestamps: timestamps.map({$0.timestamp}))
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(timestampedCurrencyExchanges.currencyExchanges.map{NSCurrencyExchange(currencyExchange: $0)}, forKey: "currencyExchanges")
        aCoder.encode(timestampedCurrencyExchanges.timestamps.map{NSTimestamp(timestamp: $0)}, forKey: "timestamps")
    }
    
    // MARK: Archiving Paths
        
    static func save(_ timestampedCurrencyExchangesArray: TimestampedCurrencyExchanges, forCurrency: Currency) {
        let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("\(forCurrency.code).timestampedExchangeRates")
        let timestampedCurrencyExchanges = NSTimestampedCurrencyExchanges(timestampedCurrencyExchanges: timestampedCurrencyExchangesArray)

        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: timestampedCurrencyExchanges, requiringSecureCoding: false)
            try data.write(to: archiveURL)
            os_log("TimestampedCurrencyExchanges successfully saved.", log: OSLog.default, type: .debug)
        } catch {
            os_log("Failed to save timestampedCurrencyExchanges...", log: OSLog.default, type: .error)
        }
    }

    static func loadTimestampedCurrencyExchanges(forCurrency: Currency) -> TimestampedCurrencyExchanges? {
        let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("\(forCurrency.code).timestampedExchangeRates")
        if let nsData = NSData(contentsOf: archiveURL) {
            do {
                let data = Data(referencing:nsData)
                os_log("TimestampedCurrencyExchanges loaded", log: OSLog.default, type: .debug)
                if let loadedTimestampedCurrencyExchanges = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? NSTimestampedCurrencyExchanges {
                    let timestampedCurrencyExchanges = loadedTimestampedCurrencyExchanges.timestampedCurrencyExchanges
                    return timestampedCurrencyExchanges
                }
            } catch {
                os_log("Couldn't read file", log: OSLog.default, type: .error)
                return nil
            }
        }
        return nil
    }
}
