//
//  FirebaseValidator.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 9/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

/// Validates Firebase event names, parameter names, and parameter values
/// according to Firebase Analytics requirements.
///
/// Handles sanitization of invalid data to ensure Firebase compatibility.
/// Uses instance-based methods to allow for configuration per validator instance.
class FirebaseValidator {
    
    // MARK: - Validation Constants
    
    /// Constants used for Firebase validation rules.
    enum Validation {
        /// Maximum length for event names (40 characters)
        static let eventNameMaxLength = 40
        
        /// Maximum length for user property names (24 characters)
        static let userPropertyNameMaxLength = 24
        
        /// Maximum length for parameter names (40 characters)
        static let parameterNameMaxLength = 40
        
        /// Maximum length for parameter values in standard mode (100 characters)
        static let paramValueMaxLength = 100
        
        /// Maximum length for parameter values in GA 360 mode (500 characters)
        static let paramValueMaxLengthGA360 = 500
        
        /// Maximum length for user property values (36 characters)
        static let userPropertyValueMaxLength = 36
        
        /// Reserved prefixes that cannot be used for event names, parameter names, or user properties
        static let reservedPrefixes = ["firebase_", "google_", "ga_"]
        
        /// Reserved user property names that cannot be used.
        /// These are automatically set by Firebase and cannot be overridden.
        static let reservedUserPropertyNames: Set<String> = [
            "first_open_time",
            "last_deep_link_referrer",
            "user_id"
        ]
        
        /// Event names reserved by Firebase that should not be used.
        /// Events with these names will be dropped and an error event will be logged.
        static let reservedEventNames: Set<String> = [
            "ad_activeview",
            "ad_click",
            "ad_exposure",
            "ad_query",
            "ad_reward",
            "adunit_exposure",
            "app_clear_data",
            "app_exception",
            "app_remove",
            "app_store_refund",
            "app_store_subscription_cancel",
            "app_store_subscription_convert",
            "app_store_subscription_renew",
            "app_update",
            "app_upgrade",
            "dynamic_link_app_open",
            "dynamic_link_app_update",
            "dynamic_link_first_open",
            "error",
            "firebase_campaign",
            "first_open",
            "first_visit",
            "notification_dismiss",
            "notification_foreground",
            "notification_open",
            "notification_receive",
            "os_update",
            "session_start",
            "session_start_with_rollout",
            "user_engagement"
        ]
        
        /// Validation strategy options
        enum Strategy {
            /// Replace invalid characters with underscore
            static let replace = "replace"
            /// Remove invalid characters entirely
            static let remove = "remove"
        }
    }
    
    // MARK: - Properties
    
    private var invalidCharStrategy: String = Validation.Strategy.replace
    private var ga360Mode: Bool = false
    private let logger: LoggerProtocol?
    
    public init(logger: LoggerProtocol? = nil) {
        self.logger = logger
    }
    
    // MARK: - Configuration
    
    /// Sets the strategy for handling invalid characters in names.
    /// - Parameter strategy: Either "replace" or "remove"
    public func setInvalidCharStrategy(_ strategy: String) {
        invalidCharStrategy = strategy
    }
    
    /// Sets whether to use GA 360 parameter value length limits (500 chars vs 100).
    /// - Parameter enabled: true for 500 char limit, false for 100 char limit
    public func setGA360Mode(_ enabled: Bool) {
        ga360Mode = enabled
    }
    
    // MARK: - Validation Methods
    
    /// Validates and sanitizes Firebase event name.
    /// Returns a valid Firebase-compatible event name, or nil if the name cannot be used.
    /// Logs warnings for sanitization and errors for invalid input.
    /// - Parameter name: The event name to validate
    /// - Returns: Sanitized event name, or nil if the name is invalid and cannot be sanitized
    public func validateEventName(_ name: String) -> String? {
        // Check if event name is reserved by Firebase (case-insensitive)
        if Validation.reservedEventNames.contains(name.lowercased()) {
            logger?.error(category: LogCategory.firebase, "Event name '\(name)' is reserved by Firebase and cannot be used")
            return nil
        }
        
        return validateName(name, sanitizationPrefix: "event_", nameType: "Event name", maxLength: Validation.eventNameMaxLength)
    }
    
    /// Validates and sanitizes Firebase user property name.
    /// Returns a valid Firebase-compatible user property name, or nil if the name cannot be used.
    /// Logs warnings for sanitization and errors for invalid input.
    /// - Parameter name: The user property name to validate
    /// - Returns: Sanitized user property name, or nil if the name is invalid and cannot be sanitized
    public func validateUserPropertyName(_ name: String) -> String? {
        // Check if user property name is reserved by Firebase (case-insensitive)
        if Validation.reservedUserPropertyNames.contains(name.lowercased()) {
            logger?.error(category: LogCategory.firebase, "User property name '\(name)' is reserved by Firebase and cannot be used")
            return nil
        }
        
        return validateName(name, sanitizationPrefix: "prop_", nameType: "User property name", maxLength: Validation.userPropertyNameMaxLength)
    }
    
    /// Validates and sanitizes Firebase parameter name.
    /// Returns a valid Firebase-compatible parameter name, or nil if the name cannot be used.
    /// Logs warnings for sanitization and errors for invalid input.
    /// - Parameter name: The parameter name to validate
    /// - Returns: Sanitized parameter name, or nil if the name is invalid and cannot be sanitized
    public func validateParameterName(_ name: String) -> String? {
        return validateName(name, sanitizationPrefix: "param_", nameType: "Parameter name", maxLength: Validation.parameterNameMaxLength)
    }
    
    /// Validates and truncates Firebase parameter value if needed.
    /// Logs warnings for truncation.
    /// - Parameter value: The parameter value to validate
    /// - Returns: Validated/truncated parameter value
    public func validateParameterValue(_ value: String) -> String {
        let maxLength = ga360Mode 
            ? Validation.paramValueMaxLengthGA360 
            : Validation.paramValueMaxLength
        
        if value.count <= maxLength {
            return value
        }
        
        let truncated = String(value.prefix(maxLength))
        logger?.warn(category: LogCategory.firebase, "Parameter value truncated to \(maxLength) characters ('\(value)' → '\(truncated)')")
        return truncated
    }
    
    /// Validates and truncates Firebase user property value if needed.
    /// Logs warnings for truncation.
    /// - Parameter value: The user property value to validate
    /// - Returns: Validated/truncated user property value
    public func validateUserPropertyValue(_ value: String) -> String {
        let maxLength = Validation.userPropertyValueMaxLength
        
        if value.count <= maxLength {
            return value
        }
        
        let truncated = String(value.prefix(maxLength))
        logger?.warn(category: LogCategory.firebase, "User property value truncated to \(maxLength) characters ('\(value)' → '\(truncated)')")
        return truncated
    }
    
    // MARK: - Private Helpers
    
    /// Common validation logic for Firebase names (events, parameters, user properties).
    /// Returns a valid Firebase-compatible name, or nil if the name cannot be sanitized.
    /// Logs warnings for sanitization and errors for invalid input.
    /// - Parameters:
    ///   - name: The name to validate
    ///   - sanitizationPrefix: Prefix to add if name doesn't start with letter
    ///   - nameType: Type description for error messages
    ///   - maxLength: Maximum allowed length
    /// - Returns: Sanitized name, or nil if the name is invalid and cannot be sanitized
    private func validateName(_ name: String, sanitizationPrefix: String, nameType: String, maxLength: Int) -> String? {
        // 1. Check empty
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            logger?.error(category: LogCategory.firebase, "\(nameType) is empty and cannot be used")
            return nil
        }
        
        // 2. Try to sanitize
        do {
            let sanitized = try sanitizeName(name, fallbackPrefix: sanitizationPrefix, maxLength: maxLength)
            
            // Log if sanitization occurred
            if name != sanitized {
                logger?.warn(category: LogCategory.firebase, "\(nameType) sanitized ('\(name)' → '\(sanitized)')")
            }
            
            return sanitized
        } catch {
            // If sanitization fails (e.g., name is only a reserved prefix), return nil
            logger?.error(category: LogCategory.firebase, "\(nameType) '\(name)' could not be sanitized: \(error). Event/parameter will be skipped")
            return nil
        }
    }
    
    /// Sanitizes Firebase name to be Firebase-compatible.
    /// Steps: remove reserved prefixes → replace/remove invalid chars → clean underscores → ensure letter start → truncate
    /// - Parameters:
    ///   - name: The name to sanitize
    ///   - fallbackPrefix: Prefix to add if name doesn't start with letter
    ///   - maxLength: Maximum allowed length
    /// - Returns: Firebase-compatible name
    /// - Throws: Error if name is only a reserved prefix
    private func sanitizeName(_ name: String, fallbackPrefix: String, maxLength: Int) throws -> String {
        // Step 1: Remove reserved prefixes
        var result = try removeReservedPrefixes(name)
        
        // Step 2: Handle invalid characters based on strategy
        if invalidCharStrategy == Validation.Strategy.replace {
            // Replace invalid characters with underscore
            result = result.replacingOccurrences(of: "[^a-zA-Z0-9_]", with: "_", options: .regularExpression)
        } else {
            // Remove invalid characters completely
            result = result.replacingOccurrences(of: "[^a-zA-Z0-9_]", with: "", options: .regularExpression)
        }
        
        // Step 3: Clean up multiple underscores
        result = result.replacingOccurrences(of: "_+", with: "_", options: .regularExpression)
        
        // Step 4: Remove leading/trailing underscores
        result = result.replacingOccurrences(of: "^_+|_+$", with: "", options: .regularExpression)
        
        // Step 5: Ensure starts with a letter (only if needed after cleanup)
        if result.isEmpty || !result.first!.isLetter {
            result = fallbackPrefix + result
        }
        
        // Step 6: Truncate if too long
        if result.count > maxLength {
            result = String(result.prefix(maxLength))
        }
        
        // Step 7: Final fallback if somehow still empty
        if result.isEmpty {
            result = fallbackPrefix.replacingOccurrences(of: "_", with: "") + "_fallback"
        }
        
        return result
    }
    
    /// Removes reserved Firebase prefixes from name.
    /// - Parameter name: The name to process
    /// - Returns: Name without reserved prefixes
    /// - Throws: `FirebaseError.reservedPrefixOnly` if name is only a reserved prefix
    private func removeReservedPrefixes(_ name: String) throws -> String {
        let lower = name.lowercased()
        var result = name
        
        if lower.hasPrefix("firebase_") {
            result = String(name.dropFirst(9)) // Remove "firebase_"
        } else if lower.hasPrefix("google_") {
            result = String(name.dropFirst(7))  // Remove "google_"
        } else if lower.hasPrefix("ga_") {
            result = String(name.dropFirst(3))  // Remove "ga_"
        }
        
        // If removing prefix left us with empty string, this is invalid input
        if result.isEmpty {
            throw FirebaseError.reservedPrefixOnly(name)
        }
        
        return result
    }
}

