//
//  NameSanitizer.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 10/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

/// Handles sanitization of Firebase names (events, parameters, user properties).
class NameSanitizer {
    
    // MARK: - Constants
    
    static let eventNameMaxLength = 40
    static let userPropertyNameMaxLength = 24
    static let parameterNameMaxLength = 40
    static let reservedPrefixes = ["firebase_", "google_", "ga_"]
    
    enum Strategy {
        static let replace = "replace"
        static let remove = "remove"
    }
    
    // MARK: - Properties
    
    private var invalidCharStrategy: String
    private let logger: LoggerProtocol?
    
    init(invalidCharStrategy: String = Strategy.replace, logger: LoggerProtocol? = nil) {
        self.invalidCharStrategy = invalidCharStrategy
        self.logger = logger
    }
    
    func setInvalidCharStrategy(_ strategy: String) {
        invalidCharStrategy = strategy
    }
    
    /// Validates and sanitizes a Firebase name. Returns nil if the name cannot be sanitized.
    func sanitize(_ name: String, fallbackPrefix: String, maxLength: Int, nameType: String) -> String? {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            logger?.error(category: LogCategory.firebase, "\(nameType) is empty and cannot be used")
            return nil
        }
        
        do {
            let sanitized = try sanitizeName(name, fallbackPrefix: fallbackPrefix, maxLength: maxLength)
            
            if name != sanitized {
                logger?.warn(category: LogCategory.firebase, "\(nameType) sanitized ('\(name)' → '\(sanitized)')")
            }
            
            return sanitized
        } catch {
            logger?.error(category: LogCategory.firebase, "\(nameType) '\(name)' could not be sanitized: \(error). Event/parameter will be skipped")
            return nil
        }
    }
    
    // MARK: - Private Helpers
    
    private func sanitizeName(_ name: String, fallbackPrefix: String, maxLength: Int) throws -> String {
        var result = try removeReservedPrefixes(name)
        
        if invalidCharStrategy == Strategy.replace {
            result = result.replacingOccurrences(of: "[^a-zA-Z0-9_]", with: "_", options: .regularExpression)
        } else {
            result = result.replacingOccurrences(of: "[^a-zA-Z0-9_]", with: "", options: .regularExpression)
        }
        
        result = result.replacingOccurrences(of: "_+", with: "_", options: .regularExpression)
        result = result.replacingOccurrences(of: "^_+|_+$", with: "", options: .regularExpression)
        
        if result.isEmpty || !result.first!.isLetter {
            result = fallbackPrefix + result
        }
        
        if result.count > maxLength {
            result = String(result.prefix(maxLength))
        }
        
        if result.isEmpty {
            result = fallbackPrefix.replacingOccurrences(of: "_", with: "") + "_fallback"
        }
        
        return result
    }
    
    private func removeReservedPrefixes(_ name: String) throws -> String {
        let lower = name.lowercased()
        var result = name
        
        for prefix in Self.reservedPrefixes {
            if lower.hasPrefix(prefix) {
                result = String(name.dropFirst(prefix.count))
                break
            }
        }
        
        if result.isEmpty {
            throw FirebaseError.reservedPrefixOnly(name)
        }
        
        return result
    }
}

