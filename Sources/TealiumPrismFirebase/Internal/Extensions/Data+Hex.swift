//
//  Data+Hex.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 25/11/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation

extension Data {
    /// Creates data from a string of hexadecimal digits, two per byte, in upper or lower case.
    ///
    /// Returns `nil` if the string has an odd length or contains anything other than hexadecimal digits,
    /// including a sign or a `0x` prefix, which `UInt8(_:radix:)` would accept.
    init?(hexEncoded hex: String) {
        let digits = Array(hex.utf8)
        guard digits.count.isMultiple(of: 2) else {
            return nil
        }
        var data = Data(capacity: digits.count / 2)
        for index in stride(from: 0, to: digits.count, by: 2) {
            guard let high = Self.hexValue(of: digits[index]),
                  let low = Self.hexValue(of: digits[index + 1]) else {
                return nil
            }
            data.append(high << 4 | low)
        }
        self = data
    }

    private static func hexValue(of digit: UInt8) -> UInt8? {
        switch digit {
        case UInt8(ascii: "0")...UInt8(ascii: "9"):
            digit - UInt8(ascii: "0")
        case UInt8(ascii: "a")...UInt8(ascii: "f"):
            digit - UInt8(ascii: "a") + 10
        case UInt8(ascii: "A")...UInt8(ascii: "F"):
            digit - UInt8(ascii: "A") + 10
        default:
            nil
        }
    }
}
