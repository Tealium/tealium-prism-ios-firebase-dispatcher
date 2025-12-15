//
//  FirebaseValidator.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 9/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

/// Validates Firebase event names, parameter names, and parameter values.
class FirebaseValidator {
    
    /// Maximum number of parameters allowed per Firebase Analytics event.
    /// Firebase Analytics allows up to 25 event parameters per event.
    /// Reference: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#logevent_:parameters:
    static let maxEventParameters = 25
    
    // MARK: - Properties
    
    private let nameSanitizer: NameSanitizer
    private let valueValidator: ValueValidator
    private var ga360Mode: Bool = false
    private let logger: LoggerProtocol?
    
    public init(logger: LoggerProtocol? = nil) {
        self.logger = logger
        self.nameSanitizer = NameSanitizer(invalidCharStrategy: NameSanitizer.Strategy.replace, logger: logger)
        self.valueValidator = ValueValidator(logger: logger)
    }
    
    // MARK: - Configuration
    
    public func setInvalidCharStrategy(_ strategy: String) {
        nameSanitizer.setInvalidCharStrategy(strategy)
    }
    
    public func setGA360Mode(_ enabled: Bool) {
        ga360Mode = enabled
    }
    
    // MARK: - Validation Methods
    
    public func validateEventName(_ name: String) -> String? {
        if ReservedNamesChecker.isReservedEventName(name) {
            logger?.error(category: LogCategory.firebase, "Event name '\(name)' is reserved by Firebase and cannot be used")
            return nil
        }
        
        return nameSanitizer.sanitize(name, 
                                      fallbackPrefix: "event_", 
                                      maxLength: NameSanitizer.eventNameMaxLength,
                                      nameType: "Event name")
    }
    
    public func validateUserPropertyName(_ name: String) -> String? {
        if ReservedNamesChecker.isReservedUserPropertyName(name) {
            logger?.error(category: LogCategory.firebase, "User property name '\(name)' is reserved by Firebase and cannot be used")
            return nil
        }
        
        return nameSanitizer.sanitize(name, 
                                      fallbackPrefix: "prop_", 
                                      maxLength: NameSanitizer.userPropertyNameMaxLength,
                                      nameType: "User property name")
    }
    
    public func validateParameterName(_ name: String) -> String? {
        return nameSanitizer.sanitize(name, 
                                      fallbackPrefix: "param_", 
                                      maxLength: NameSanitizer.parameterNameMaxLength,
                                      nameType: "Parameter name")
    }
    
    public func validateParameterValue(_ value: String) -> String {
        let maxLength = ga360Mode 
            ? ValueValidator.paramValueMaxLengthGA360 
            : ValueValidator.paramValueMaxLength
        
        return valueValidator.validateAndTruncate(value, 
                                                   maxLength: maxLength,
                                                   valueType: "Parameter value")
    }
    
    public func validateUserPropertyValue(_ value: String) -> String {
        return valueValidator.validateAndTruncate(value, 
                                                   maxLength: ValueValidator.userPropertyValueMaxLength,
                                                   valueType: "User property value")
    }
    
    /// Checks if the event name supports the `items` parameter.
    public func supportsItemsParameter(_ eventName: String) -> Bool {
        return ReservedNamesChecker.supportsItemsParameter(eventName)
    }
    
    /// Enforces Firebase's maximum parameters per event limit.
    /// - Parameters:
    ///   - parameters: The parameters dictionary to validate
    ///   - eventName: The event name (used for logging)
    /// - Returns: Parameters dictionary limited to maxEventParameters, or original if within limit
    public func enforceParameterLimit(_ parameters: [String: Any], eventName: String) -> [String: Any] {
        guard parameters.count > Self.maxEventParameters else { return parameters }
        
        let excessCount = parameters.count - Self.maxEventParameters
        logger?.warn(category: LogCategory.firebase,
            "Event '\(eventName)' has \(parameters.count) parameters, " +
            "exceeding Firebase limit of \(Self.maxEventParameters). Removing \(excessCount) excess parameter(s)")
        
        return Dictionary(uniqueKeysWithValues: Array(parameters.prefix(Self.maxEventParameters)))
    }
}

