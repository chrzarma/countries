//
//  CustomCurrencyFormatterTests.swift
//  CountriesTests
//
//  Created by Christian Zarmakoupis on 24/11/2020.
//  Copyright © 2020 Chris Zarmakoupis. All rights reserved.
//

import XCTest

class CustomCurrencyFormatterTests: XCTestCase {
    func test_validOutputs_for_AllCases() {
        XCTAssertEqual(CustomCurrencyFormatter.input("1.23"), "1.23")
        XCTAssertEqual(CustomCurrencyFormatter.input("invalid"), nil)
        XCTAssertEqual(CustomCurrencyFormatter.input("1.23000"), "1.23")
        XCTAssertEqual(CustomCurrencyFormatter.input("1.2372"), "1.24")
        XCTAssertEqual(CustomCurrencyFormatter.input("1.2342"), "1.23")
        XCTAssertEqual(CustomCurrencyFormatter.input("0.000032"), "0.000032")
        XCTAssertEqual(CustomCurrencyFormatter.input("0.0000323343"), "0.000032")
        XCTAssertEqual(CustomCurrencyFormatter.input("0.0000328103"), "0.000033")
    }
}
