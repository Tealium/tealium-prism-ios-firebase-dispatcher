//
//  DataItemExtractor+NumericConversion.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 27/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

/// Extension providing numeric and boolean conversion helpers for DataItemExtractor.
///
/// These helpers handle the case where values are sent as strings (e.g., from constants)
/// but need to be converted to numeric types or booleans for Firebase Analytics.
///
/// Example:
/// ```swift
/// // Handles both numeric and string representations:
/// let timeout1 = data.getAsDouble(key: "timeout")  // 1800.5 or "1800.5"
/// let enabled = data.getBoolValue(key: "enabled")  // true or "true"
/// ```
extension DataItemExtractor {
    
    // MARK: - Numeric Conversion
    
    /// Extracts a Double value with automatic String → Double conversion.
    ///
    /// Uses the underlying extractor's `get(key:as: Double.self)`, which already handles
    /// Int → Double conversion. Falls back to parsing from String if needed.
    ///
    /// - Parameter key: The key to look up
    /// - Returns: The Double value if found and valid, nil otherwise
    func getAsDouble(key: String) -> Double? {
        if let value = get(key: key, as: Double.self) {
            return value
        }
        if let stringValue = get(key: key, as: String.self),
           let doubleValue = Double(stringValue) {
            return doubleValue
        }
        return nil
    }
    
    // MARK: - Boolean Conversion
    
    /// Extracts a boolean value with automatic String/Int → Bool conversion.
    ///
    /// This method first attempts to get the value as a Bool.
    /// If that fails, it attempts to get the value as an Int and convert it.
    /// If that also fails, it attempts to get the value as a String and convert it.
    ///
    /// Supported conversions:
    /// - Bool: true/false → direct return
    /// - Int: 0 → false, non-zero → true
    /// - String (case-insensitive): "true", "1", "yes" → true; "false", "0", "no" → false
    ///
    /// - Parameter key: The key to look up
    /// - Returns: The boolean value if found and valid, nil otherwise
    func getBoolValue(key: String) -> Bool? {
        // Try direct boolean extraction first
        if let value = get(key: key, as: Bool.self) {
            return value
        }
        
        // Try integer conversion (0 = false, non-zero = true)
        if let intValue = get(key: key, as: Int.self) {
            return intValue != 0
        }
        
        // Fall back to string conversion
        if let stringValue = get(key: key, as: String.self) {
            let lowercased = stringValue.lowercased().trimmingCharacters(in: .whitespaces)
            switch lowercased {
            case "true", "1", "yes":
                return true
            case "false", "0", "no":
                return false
            default:
                return nil
            }
        }
        
        return nil
    }
}
