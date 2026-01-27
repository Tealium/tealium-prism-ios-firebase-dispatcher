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
/// ## Expected Payload
///
/// ```
/// payload = [
///     "command": "logevent",
///     "firebase_event_name": "purchase",
///     "firebase_event_params": [
///         "param_value": 99.99,
///         "param_currency": "USD",
///         "param_items": [
///             "param_items_item_id": ["SKU001", "SKU002"],
///             "param_items_item_name": ["Widget", "Gadget"],
///             "param_items_price": [29.99, 70.00]
///         ]
///     ]
/// ]
/// ```
class LogEventCommand: FirebaseCommandProtocol {
    
    private let firebaseInstance: FirebaseCommand
    private let logger: LoggerProtocol?
    
    
    public init(firebaseInstance: FirebaseCommand, logger: LoggerProtocol?) {
        self.firebaseInstance = firebaseInstance
        self.logger = logger
    }
    
    public let name = FirebaseConstants.LogEvent.name
    typealias Param = FirebaseConstants.LogEvent.Param
    
    public func execute(payload: DataObject) -> Bool {
        logger?.debug(category: LogCategory.firebase, "Executing LogEvent command")
        
        // 1. Extract event name
        guard let eventName = extractEventName(from: payload) else {
            return false
        }
        
        // 2. Build parameters from payload
        let parameters = buildParameters(from: payload, eventName: eventName)
        
        // 3. Log the event
        logEvent(eventName, with: parameters)
        
        return true
    }
    
    /// Extracts the event name from payload.
    private func extractEventName(from payload: DataObject) -> String? {
        guard let rawEventName = payload.get(key: Param.eventName, as: String.self) else {
            logger?.warn(category: LogCategory.firebase, "Missing 'firebase_event_name' in payload")
            return nil
        }
        
        return FirebaseEvent.map(rawEventName)
    }
    
    /// Builds all Firebase parameters from payload (including items).
    private func buildParameters(from payload: DataObject, eventName: String) -> [String: Any] {
        guard let eventParamsData = payload.getDataItem(key: Param.eventParams),
              let eventParamsDict = eventParamsData.getDataDictionary() else {
            return [:]
        }
        
        var parameters: [String: Any] = [:]
        
        // Build items first (if present)
        if let items = buildItems(from: eventParamsDict, eventName: eventName) {
            parameters[AnalyticsParameterItems] = items  // Use Firebase SDK constant "items"
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
            // Skip items - handled separately (both Tealium and Firebase conventions)
            guard key != Param.items,
                  key != AnalyticsParameterItems else { 
                continue 
            }
            
            let paramName = FirebaseParameter.map(key)
            result[paramName] = value
        }
        
        return result
    }
    
    /// Builds Firebase items array from parallel arrays format.
    /// - Returns: Array of item dictionaries, or nil if no items found.
    ///
    /// Supports both Tealium convention (`param_items`) and Firebase convention (`items`).
    private func buildItems(from eventParamsDict: [String: DataItem], eventName: String) -> [[String: Any]]? {
        // Try Tealium convention first: "param_items"
        var itemsData = eventParamsDict.getDataItem(key: Param.items)
        
        // If not found, try Firebase convention: "items"
        if itemsData == nil {
            itemsData = eventParamsDict.getDataItem(key: AnalyticsParameterItems)
        }
        
        guard let itemsData = itemsData,
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
            let paramName = FirebaseItemParameter.map(key)
             item[paramName] = array[index]
        }
        
        return item
    }
    
    /// Extracts only array values from dictionary.
    private func extractArrays(from dict: [String: DataInput]) -> [String: [DataInput]] {
        dict.compactMapValues { $0 as? [DataInput] }
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


