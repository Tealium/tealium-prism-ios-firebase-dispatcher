//
//  ValueValidator.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 10/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

/// Handles validation and truncation of Firebase parameter and user property values.
class ValueValidator {
    
    // MARK: - Constants
    
    static let paramValueMaxLength = 100
    static let paramValueMaxLengthGA360 = 500
    static let userPropertyValueMaxLength = 36
    
    // MARK: - Properties
    
    private let logger: LoggerProtocol?
    
    init(logger: LoggerProtocol? = nil) {
        self.logger = logger
    }
    
    /// Validates and truncates a value if it exceeds the maximum length.
    func validateAndTruncate(_ value: String, maxLength: Int, valueType: String) -> String {
        if value.count <= maxLength {
            return value
        }
        
        let truncated = String(value.prefix(maxLength))
        logger?.warn(category: LogCategory.firebase, "\(valueType) truncated to \(maxLength) characters ('\(value)' → '\(truncated)')")
        return truncated
    }
}

