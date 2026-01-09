//
//  LogEventCommand.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 10/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import FirebaseAnalytics
import TealiumPrismCore

/// Command for logging Firebase Analytics events with parameter and item support.
///
/// Logs events to Firebase Analytics with optional parameters and items (for e-commerce events).
/// Supports both predefined Firebase events and custom events.
///
/// Firebase SDK Reference:
/// - https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#logevent_:parameters:
///
/// ## Complete Flow Example
///
/// ### 1. Configuration (FirebaseSettingsBuilder)
/// ```swift
/// Modules.firebaseDispatcher(forcingSettings: { builder in
///     builder
///         // TODO: Add configuration here
/// })
/// ```
///
/// ### 2. Tracking Call (Your Code)
/// ```swift
/// tealium.track("purchase", data: [
///     "tealium_event": "purchase",
///     "order_total": 99.99,
///     "currency_code": "USD",
///     
///     // Parallel arrays for products
///     "product_id": ["SKU001", "SKU002"],
///     "product_name": ["Widget", "Gadget"],
///     "product_price": [29.99, 70.00]
/// ])
/// ```
///
/// ### 3. After Mappings (What This Command Receives)
/// ```
/// payload = [
///     "logevent": [
///         "firebase_event_name": "purchase",
///         "firebase_event_params": [
///             "param_value": 99.99,                // Event parameters have param_ prefix
///             "param_currency": "USD",
///             "param_items": [                    // Items container
///                 "param_items_item_id": ["SKU001", "SKU002"],      // Item parameters have param_items_ prefix
///                 "param_items_item_name": ["Widget", "Gadget"],
///                 "param_items_price": [29.99, 70.00]
///             ]
///         ]
///     ]
/// ]
/// ```
class LogEventCommand: FirebaseCommandProtocol {
    
    private let firebaseInstance: FirebaseCommand
    private let validator: FirebaseValidator
    private let logger: LoggerProtocol?
    
    
    public init(firebaseInstance: FirebaseCommand, validator: FirebaseValidator, logger: LoggerProtocol?) {
        self.firebaseInstance = firebaseInstance
        self.validator = validator
        self.logger = logger
    }
    
    public let name = FirebaseConstants.LogEvent.name
    
    public func execute(payload: DataObject) -> Bool {
        logger?.debug(category: LogCategory.firebase, "Executing LogEvent command")
        
        guard let logEventData = payload.getDataItem(key: FirebaseConstants.LogEvent.name)?
            .getDataDictionary() else {
            return false
        }
        
        // 1. Extract and validate event name
        guard let eventName = extractEventName(from: logEventData) else {
            return false
        }
        
        // 2. Build parameters from logevent data
        var parameters = buildParameters(from: logEventData, eventName: eventName)
        
        // 3. Enforce Firebase limits
        parameters = validator.enforceParameterLimit(parameters, eventName: eventName)
        
        // 4. Log the event
        logEvent(eventName, with: parameters)
        
        return true
    }
    
    /// Extracts and validates the event name from logevent data.
    private func extractEventName(from logEventData: [String: DataItem]) -> String? {
        guard let rawEventName = logEventData.get(key: FirebaseConstants.LogEvent.Param.eventName, as: String.self) else {
            logger?.warn(category: LogCategory.firebase, "Missing 'firebase_event_name' in logevent data")
            return nil
        }
        
        let mappedName = FirebaseEvent.map(rawEventName)
        guard let validatedName = validator.validateEventName(mappedName) else {
            logger?.warn(category: LogCategory.firebase, "Invalid event name '\(rawEventName)' (mapped to '\(mappedName)')")
            return nil
        }
        return validatedName
    }
    
    /// Builds all Firebase parameters from logevent data (including items).
    private func buildParameters(from logEventData: [String: DataItem], eventName: String) -> [String: Any] {
        guard let eventParamsDict = logEventData.getDataItem(key: FirebaseConstants.LogEvent.Param.eventParams)?
            .getDataDictionary() else {
            return [:]
        }
        
        var parameters: [String: Any] = [:]
        
        // Build items first (if present)
        if let items = buildItems(from: eventParamsDict, eventName: eventName) {
            parameters[FirebaseConstants.LogEvent.Param.items] = items
            warnIfEventWithoutItemsSupport(eventName)
        }
        
        // Build regular parameters
        let regularParams = buildRegularParameters(from: eventParamsDict)
        parameters.merge(regularParams) { _, new in new }
        
        return parameters
    }
    
    /// Builds regular parameters (excluding items).
    private func buildRegularParameters(from eventParamsDict: [String: DataItem]) -> [String: Any] {
        let params = eventParamsDict.toDataObject().asDictionary()
        var result: [String: Any] = [:]
        
        for (key, value) in params {
            // Skip items - handled separately
            guard key != FirebaseConstants.LogEvent.Param.items else { continue }
            
            guard let paramName = mapAndValidateParameter(key),
                  let convertedValue = convertValue(value, for: paramName) else {
                continue
            }
            result[paramName] = convertedValue
        }
        
        return result
    }
    
    /// Builds Firebase items array from parallel arrays format.
    /// - Returns: Array of item dictionaries, or nil if no items found.
    private func buildItems(from eventParamsDict: [String: DataItem], eventName: String) -> [[String: Any]]? {
        guard let itemsData = eventParamsDict.getDataItem(key: FirebaseConstants.LogEvent.Param.items),
              let itemsDict = itemsData.getDataDictionary() else {
            return nil
        }
        
        let parallelArrays = itemsDict.toDataObject().asDictionary()
        let items = buildItemsFromParallelArrays(parallelArrays)
        
        guard !items.isEmpty else { return nil }
        
        logger?.debug(category: LogCategory.firebase, "Event '\(eventName)' includes \(items.count) item(s)")
        return items
    }
    
    /// Converts parallel arrays to array of item dictionaries.
    /// Input:  { "param_items_item_id": ["SKU1", "SKU2"], "param_items_item_name": ["P1", "P2"] }
    /// Output: [["item_id": "SKU1", "item_name": "P1"], ["item_id": "SKU2", "item_name": "P2"]]
    private func buildItemsFromParallelArrays(_ parallelArrays: [String: DataInput]) -> [[String: Any]] {
        let arrays = extractArrays(from: parallelArrays)
        
        guard let itemCount = arrays.values.map(\.count).max(), itemCount > 0 else {
            return []
        }
        
        // Warn if arrays have mismatched lengths
        if !arrays.values.allSatisfy({ $0.count == itemCount }) {
            let mismatchedKeys = arrays.filter { $0.value.count != itemCount }.map(\.key)
            logger?.warn(category: LogCategory.firebase,
                "Item arrays have mismatched lengths (expected: \(itemCount)). " +
                "Arrays with shorter lengths will have missing values for some items. " +
                "Mismatched keys: \(mismatchedKeys.joined(separator: ", "))")
        }
        
        return (0..<itemCount).compactMap { index in
            let item = buildItem(from: arrays, at: index)
            return item.isEmpty ? nil : item
        }
    }
    
    /// Builds a single item dictionary from parallel arrays at given index.
    private func buildItem(from arrays: [String: [DataInput]], at index: Int) -> [String: Any] {
        var item: [String: Any] = [:]
        
        for (key, array) in arrays where index < array.count {
            guard let paramName = mapAndValidateItemParameter(key),
                  let value = convertValue(array[index], for: paramName) else {
                continue
            }
            item[paramName] = value
        }
        
        return item
    }
    
    /// Extracts only array values from dictionary.
    private func extractArrays(from dict: [String: DataInput]) -> [String: [DataInput]] {
        dict.compactMapValues { $0 as? [DataInput] }
    }
    
    /// Maps and validates an event parameter key.
    private func mapAndValidateParameter(_ key: String) -> String? {
        let mapped = FirebaseParameter.map(key)
        return validator.validateParameterName(mapped)
    }
    
    /// Maps and validates an item parameter key.
    private func mapAndValidateItemParameter(_ key: String) -> String? {
        let mapped = FirebaseItemParameter.map(key)
        return validator.validateParameterName(mapped)
    }
    
    /// Converts a value to Firebase-compatible type (String, Int, Double, Float, Int64, Bool, NSNumber).
    private func convertValue(_ value: DataInput, for parameterName: String) -> Any? {
        switch value {
        case let intValue as Int:
            return intValue
        case let int64Value as Int64:
            return int64Value
        case let doubleValue as Double:
            return doubleValue
        case let floatValue as Float:
            return floatValue
        case let boolValue as Bool:
            return boolValue
        case let stringValue as String:
            return validator.validateParameterValue(stringValue)
        case let nsNumberValue as NSNumber:
            // NSNumber can represent various numeric types - pass through as-is
            // Firebase SDK will handle the conversion
            return nsNumberValue
        default:
            let valueType = String(describing: type(of: value))
            logger?.warn(category: LogCategory.firebase,
                "Parameter '\(parameterName)' has unsupported type '\(valueType)'. " +
                "Firebase supports String, Int, Int64, Double, Float, Bool, NSNumber. Skipping.")
            return nil
        }
    }
    
    /// Logs info if items are used with an event that doesn't typically support items parameter.
    private func warnIfEventWithoutItemsSupport(_ eventName: String) {
        guard !validator.supportsItemsParameter(eventName) else { return }
        
        logger?.info(category: LogCategory.firebase,
            "Event '\(eventName)' includes 'items' parameter. " +
            "Note: Firebase Analytics typically uses 'items' with events like 'purchase', 'add_to_cart', 'select_item', etc. " +
            "Data will be sent to Firebase. Item-scoped dimensions behavior with this event may require testing.")
    }
    
    /// Logs the event to Firebase.
    private func logEvent(_ eventName: String, with parameters: [String: Any]) {
        if parameters.isEmpty {
            logger?.debug(category: LogCategory.firebase, "Logging event '\(eventName)' with no parameters")
        } else {
            logger?.debug(category: LogCategory.firebase,
                "Logging event '\(eventName)' with \(parameters.count) parameter(s): \(parameters.keys.sorted().joined(separator: ", "))")
        }
        
        firebaseInstance.logEvent(eventName, parameters: parameters.isEmpty ? nil : parameters)
    }
}


