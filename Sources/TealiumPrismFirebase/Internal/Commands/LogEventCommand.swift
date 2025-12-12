//
//  LogEventCommand.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 10/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

/// Command for logging Firebase Analytics events with parameter and item support.
class LogEventCommand: FirebaseCommandProtocol {
    
    private let firebaseInstance: FirebaseCommand
    private let validator: FirebaseValidator
    private let logger: LoggerProtocol
    
    public required init(firebaseInstance: FirebaseCommand, validator: FirebaseValidator, logger: LoggerProtocol) {
        self.firebaseInstance = firebaseInstance
        self.validator = validator
        self.logger = logger
    }
    
    public let name = FirebaseConstants.LogEvent.name
    
    public func execute(payload: DataObject) -> Bool {
        logger.debug(category: LogCategory.firebase, "Executing LogEvent command")
        
        guard let eventName = payload.get(key: FirebaseConstants.LogEvent.Param.eventName,
                                          as: String.self) else {
            return false
        }
        
        // Map to Firebase predefined event if available, otherwise use the name as-is
        let mappedEventName = FirebaseEvent.map(eventName)
        
        // Validate event name
        guard let sanitizedEventName = validator.validateEventName(mappedEventName) else {
            return false
        }
        
        // Extract event parameters
        var parameters: [String: Any] = [:]
        
        // Get event params object
        if let eventParamsDict = payload.getDataItem(key: FirebaseConstants.LogEvent.Param.eventParams)?
            .getDataDictionary() {
            // Convert [String: DataItem] to [String: DataInput]
            let eventParams = eventParamsDict.mapValues { $0.toDataInput() }
            parameters = convertAndValidateParams(eventParams)
        }
        
        // Get items array (for e-commerce)
        // First, check if items are explicitly provided under "items" key
        if let itemsData = payload.getDataItem(key: FirebaseConstants.LogEvent.Param.items) {
            // Check if items are already in array format (array of dictionaries)
            if let itemsArray = itemsData.getDataArray() as? [[String: DataInput]] {
                // Items are already in array of dictionaries format
                let items = convertArrayOfDictionariesToItems(itemsArray)
                if !items.isEmpty {
                    parameters[FirebaseConstants.LogEvent.Param.items] = items
                    logger.debug(category: LogCategory.firebase, "Event '\(sanitizedEventName)' includes \(items.count) item(s) (array format)")
                }
            } else if let itemsObjectDict = itemsData.getDataDictionary() {
                // Items are in parallel arrays format (dictionary with arrays)
                // Convert [String: DataItem] to [String: DataInput]
                let itemsObject = itemsObjectDict.mapValues { $0.toDataInput() }
                let items = convertParallelArraysToItems(itemsObject)
            if !items.isEmpty {
                parameters[FirebaseConstants.LogEvent.Param.items] = items
                    logger.debug(category: LogCategory.firebase, "Event '\(sanitizedEventName)' includes \(items.count) item(s) (parallel arrays format)")
                }
            }
        } else {
            // Auto-detect item parameters from payload (product_id, product_name, etc.)
            // These will be automatically grouped as items (parallel arrays)
            if let detectedItems = detectAndExtractItems(from: payload) {
                parameters[FirebaseConstants.LogEvent.Param.items] = detectedItems
                logger.debug(category: LogCategory.firebase, "Event '\(sanitizedEventName)' includes \(detectedItems.count) item(s) (auto-detected from item parameters)")
            }
        }
        
        // Info: Check if items parameter is used with non-e-commerce event
        // Note: GA4 documentation focuses on e-commerce events for items parameter, but does not
        // explicitly state restrictions. All examples use e-commerce events, but behavior with
        // custom events is not documented. Testing may be needed to confirm item-scoped dimensions
        // functionality with custom events.
        if parameters[FirebaseConstants.LogEvent.Param.items] != nil {
            if !validator.isEcommerceEvent(sanitizedEventName) {
                logger.info(category: LogCategory.firebase, "Event '\(sanitizedEventName)' includes 'items' parameter. Note: GA4 documentation focuses on e-commerce events for items usage (e.g., 'purchase', 'add_to_cart'). All official examples use e-commerce events. Data will be sent to Firebase and available in BigQuery. Item-scoped dimensions behavior with custom events is not documented and may require testing.")
            }
        }
        
        // Validate parameter count limit (Firebase allows max 25 parameters per event)
        let maxParameters = 25
        if parameters.count > maxParameters {
            let excessCount = parameters.count - maxParameters
            logger.warn(category: LogCategory.firebase, "Event '\(sanitizedEventName)' has \(parameters.count) parameters, exceeding Firebase limit of \(maxParameters). Removing \(excessCount) excess parameter(s)")
            
            // Keep first 25 parameters (items parameter counts as 1)
            let sortedKeys = Array(parameters.keys).sorted()
            var limitedParameters: [String: Any] = [:]
            for key in sortedKeys.prefix(maxParameters) {
                limitedParameters[key] = parameters[key]
            }
            parameters = limitedParameters
        }
        
        if parameters.isEmpty {
            logger.debug(category: LogCategory.firebase, "Logging event '\(sanitizedEventName)' with no parameters")
        } else {
            logger.debug(category: LogCategory.firebase, "Logging event '\(sanitizedEventName)' with \(parameters.count) parameter(s): \(parameters.keys.joined(separator: ", "))")
        }
        
        // Log the event
        firebaseInstance.logEvent(sanitizedEventName,
                                 parameters: parameters.isEmpty ? nil : parameters)
        
        return true
    }
    
    // MARK: - Private Helpers
    
    /// Converts and validates event parameters dictionary
    /// 
    /// **Important:** Firebase Analytics only supports String, Int, and Double as parameter values.
    /// The `items` parameter is a special exception that accepts `[[String: Any]]` (array of dictionaries).
    /// All other array/list types are not supported and will be rejected.
    private func convertAndValidateParams(_ params: [String: DataInput]) -> [String: Any] {
        var result: [String: Any] = [:]
        
        for (key, value) in params {
            // Map to Firebase predefined parameter if available (mapping expects param_ prefix)
            let mappedName = FirebaseParameter.map(key)
            
            // Validate parameter name
            guard let sanitizedName = validator.validateParameterName(mappedName) else {
                continue
            }
            
            // Skip items parameter - it's handled separately and is the only parameter that accepts array
            if sanitizedName == FirebaseConstants.LogEvent.Param.items {
                continue
            }
            
            // Convert and validate value
            // Firebase only supports String, Int, and Double - Bool and Array are not supported
            // Note: items parameter is a special exception handled separately
            if let intValue = value as? Int {
                result[sanitizedName] = intValue
            } else if let doubleValue = value as? Double {
                result[sanitizedName] = doubleValue
            } else if let stringValue = value as? String {
                let sanitizedValue = validator.validateParameterValue(stringValue)
                result[sanitizedName] = sanitizedValue
            } else {
                // Reject unsupported types (Bool, Array, Dictionary, etc.)
                // Note: Array values are not supported except for the special 'items' parameter
                let valueType = String(describing: type(of: value))
                logger.warn(category: LogCategory.firebase, "Parameter '\(sanitizedName)' has unsupported value type '\(valueType)'. Firebase Analytics only supports String, Int, and Double. This parameter will be skipped. Note: Arrays are only supported for the special 'items' parameter.")
            }
        }
        
        return result
    }
    
    /// Detects item parameters in payload and extracts them as items array.
    /// Supports all predefined Firebase item parameters and custom item parameters (up to 27).
    ///
    /// This method looks for keys that match `FirebaseItemParameter.mapping` keys (predefined)
    /// or keys starting with `param_items_` (custom item parameters).
    ///
    /// Reference: https://developers.google.com/analytics/devguides/collection/ga4/item-scoped-ecommerce
    ///
    /// - Parameter payload: The full payload dictionary
    /// - Returns: Array of item dictionaries, or nil if no item parameters found
    private func detectAndExtractItems(from payload: DataObject) -> [[String: Any]]? {
        // Collect all item parameters from payload
        // Only include values that are arrays (parallel arrays format)
        var itemsObject: [String: DataInput] = [:]
        var foundAnyItems = false
        
        // Get all keys from payload
        let payloadDict = payload.asDictionary()
        
        // Check each key in payload
        for (key, value) in payloadDict {
            // Check if it's a predefined item parameter (in FirebaseItemParameter.mapping)
            // or a custom item parameter (starts with "param_items_")
            let isPredefinedItemParam = FirebaseItemParameter.mapping.keys.contains(key)
            let isCustomItemParam = key.hasPrefix("param_items_")
            
            if isPredefinedItemParam || isCustomItemParam {
                // Only include if it's an array (parallel arrays format)
                if let arrayValue = value as? [DataInput] {
                    itemsObject[key] = arrayValue
                    foundAnyItems = true
                }
            }
        }
        
        guard foundAnyItems else { return nil }
        
        // Convert parallel arrays to items format
        return convertParallelArraysToItems(itemsObject)
    }
    
    /// Convert parallel arrays (Tealium style) to array of item dictionaries (Firebase style).
    /// Input: { "param_items_item_id": ["SKU1", "SKU2"], "param_items_item_name": ["P1", "P2"] }
    /// Output: [["item_id": "SKU1", "item_name": "P1"], ["item_id": "SKU2", "item_name": "P2"]]
    private func convertParallelArraysToItems(_ itemsObject: [String: DataInput]) -> [[String: Any]] {
        // Find first array to determine count
        var itemCount = 0
        var arrays: [String: [DataInput]] = [:]
        
        for (key, value) in itemsObject {
            if let array = value as? [DataInput] {
                arrays[key] = array
                itemCount = max(itemCount, array.count)
            }
        }
        
        guard itemCount > 0 else { return [] }
        
        // Build items array
        var items: [[String: Any]] = []
        for i in 0..<itemCount {
            var item: [String: Any] = [:]
            
            for (key, array) in arrays {
                guard i < array.count else { continue }
                
                // Map to Firebase predefined item parameter if available (mapping expects param_ prefix)
                // Custom item parameters are also supported (up to 27 per item)
                let mappedName = FirebaseItemParameter.map(key)
                
                // Validate name
                guard let sanitizedName = validator.validateParameterName(mappedName) else {
                    continue
                }
                
                // Convert value
                let value = array[i]
               if let intValue = value as? Int {
                    item[sanitizedName] = intValue
                } else if let doubleValue = value as? Double {
                    item[sanitizedName] = doubleValue
                } else if let stringValue = value as? String {
                    let sanitizedValue = validator.validateParameterValue(stringValue)
                    item[sanitizedName] = sanitizedValue
                } 
            }
            
            if !item.isEmpty {
                items.append(item)
            }
        }
        
        return items
    }
    
    /// Convert array of dictionaries to Firebase items format with proper parameter mapping.
    /// Input: [{"param_items_item_id": "SKU1", "param_items_item_name": "P1"}, ...]
    /// Output: [["item_id": "SKU1", "item_name": "P1"], ...]
    ///
    /// Custom item parameters (up to 27) are also supported and passed through.
    ///
    /// - Parameter itemsArray: Array of item dictionaries with param_items_* prefixed keys
    /// - Returns: Array of item dictionaries with Firebase parameter names
    private func convertArrayOfDictionariesToItems(_ itemsArray: [[String: DataInput]]) -> [[String: Any]] {
        var items: [[String: Any]] = []
        
        for itemDict in itemsArray {
            var item: [String: Any] = [:]
            
            for (key, value) in itemDict {
                // Map to Firebase predefined item parameter if available (mapping expects param_ prefix)
                // Custom item parameters are also supported (up to 27 per item)
                let mappedName = FirebaseItemParameter.map(key)
                
                // Validate name
                guard let sanitizedName = validator.validateParameterName(mappedName) else {
                    continue
                }
                
                // Convert value
                if let intValue = value as? Int {
                    item[sanitizedName] = intValue
                } else if let doubleValue = value as? Double {
                    item[sanitizedName] = doubleValue
                } else if let stringValue = value as? String {
                    let sanitizedValue = validator.validateParameterValue(stringValue)
                    item[sanitizedName] = sanitizedValue
                }
            }
            
            if !item.isEmpty {
                items.append(item)
            }
        }
        
        return items
    }
}

