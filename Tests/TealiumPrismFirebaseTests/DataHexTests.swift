//
//  DataHexTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 25/11/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import XCTest

@testable import TealiumPrismFirebase

final class DataHexTests: XCTestCase {

    func test_init_decodes_lowercase_uppercase_and_mixed_case_digits() {
        let expected = Data([0x00, 0x0f, 0xa5, 0xff])

        XCTAssertEqual(Data(hexEncoded: "000fa5ff"), expected)
        XCTAssertEqual(Data(hexEncoded: "000FA5FF"), expected)
        XCTAssertEqual(Data(hexEncoded: "000fA5Ff"), expected)
    }

    func test_init_with_empty_string_returns_empty_data() {
        XCTAssertEqual(Data(hexEncoded: ""), Data())
    }

    func test_init_with_odd_length_returns_nil() {
        XCTAssertNil(Data(hexEncoded: "abc"))
    }

    func test_init_with_non_hex_digit_returns_nil() {
        XCTAssertNil(Data(hexEncoded: "0g"))
        XCTAssertNil(Data(hexEncoded: "  "))
        XCTAssertNil(Data(hexEncoded: "é"))  // Two UTF-8 bytes, neither a hex digit
    }

    func test_init_rejects_sign_that_uint8_radix_accepts() {
        // `UInt8("+f", radix: 16)` is 15, so a decoder built on it would accept these.
        XCTAssertNil(Data(hexEncoded: "+f"))
        XCTAssertNil(Data(hexEncoded: "-0"))
    }

    func test_init_rejects_0x_prefix() {
        XCTAssertNil(Data(hexEncoded: "0xff"))
    }
}
