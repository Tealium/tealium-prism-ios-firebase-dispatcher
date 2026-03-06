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
///
/// Logs events to Firebase Analytics with optional parameters and items (for e-commerce events).
/// Supports both predefined Firebase events and custom events.
///
/// Firebase SDK Reference:
/// - https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#logevent_:parameters:
///
/// ## Expected Payload
///
/// ### Format 1: Object of Arrays (Tealium convention - most common)
/// ```
/// payload = [
///     "command_name": "logevent",
///     "event_name": "purchase",
///     "parameters": [
///         "param_value": 99.99,
///         "param_currency": "USD",
///         "items": [
///             "param_items_item_id": ["SKU001", "SKU002"],
///             "param_items_item_name": ["Widget", "Gadget"],
///             "param_items_price": [29.99, 70.00]
///         ]
///     ]
/// ]
/// ```
///
/// ### Format 2: Array of Objects (Firebase-ready format)
/// ```
/// payload = [
///     "command_name": "logevent",
///     "event_name": "purchase",
///     "parameters": [
///         "param_value": 99.99,
///         "param_currency": "USD",
///         "items": [
///             ["item_id": "SKU001", "item_name": "Widget", "price": 29.99],
///             ["item_id": "SKU002", "item_name": "Gadget", "price": 70.00]
///         ]
///     ]
/// ]
/// ```
class LogEventCommand: FirebaseCommandProtocol {
    
    private let firebaseInstance: FirebaseAnalyticsInterface

    init(firebaseInstance: FirebaseAnalyticsInterface) {
        self.firebaseInstance = firebaseInstance
    }
    
    let name = FirebaseCommand.logEvent.rawValue

    func execute(payload: DataObject) throws(FirebaseCommandError) {
        let eventName = try extractEventName(from: payload)
        let parameters = try buildParameters(from: payload)
        firebaseInstance.logEvent(eventName, parameters: parameters.isEmpty ? nil : parameters)
    }

    private func extractEventName(from payload: DataObject) throws(FirebaseCommandError) -> String {
        guard let rawEventName = payload.get(key: FirebaseDestination.eventName.renderedPath, as: String.self) else {
            throw FirebaseCommandError.missingParameter(FirebaseDestination.eventName.renderedPath)
        }
        
        return FirebaseEventMapper.map(rawEventName)
    }
    
    /// Builds all Firebase parameters from payload (including items).
    /// - Throws: `FirebaseCommandError.arrayLengthMismatch` if item arrays have mismatched lengths.
    private func buildParameters(from payload: DataObject) throws(FirebaseCommandError) -> [String: Any] {
        guard let eventParamsData = payload.getDataDictionary(key: FirebaseDestination.eventParams.renderedPath) else {
            return [:]
        }
        
        var parameters: [String: Any] = [:]
        
        // Build items first (if present)
        if let items = try buildItems(from: eventParamsData) {
            let itemsKey = FirebaseParameterMapper.map(FirebaseEventParameter.items.value)
            parameters[itemsKey] = items
        }
        
        // Build regular parameters
        let regularParams = buildRegularParameters(from: eventParamsData)
        parameters.merge(regularParams) { _, new in new }
        
        return parameters
    }
    
    private func buildRegularParameters(from eventParamsData: [String: DataItem]) -> [String: Any] {
        var result: [String: Any] = [:]
        
        for (key, dataItem) in eventParamsData {
            // Skip items - handled separately via the items key
            guard key != FirebaseEventParameter.items.value else {
                continue
            }

            let paramName = FirebaseParameterMapper.map(key)
            result[paramName] = dataItem.toDataInput()
        }
        
        return result
    }
    
    /// Builds Firebase items array from either parallel arrays or array of objects format.
    /// - Returns: Array of item dictionaries, or nil if no items found.
    /// - Throws: `FirebaseCommandError.arrayLengthMismatch` if item arrays have mismatched lengths.
    ///
    /// Only checks `param_items` key. This allows users to use "items" as a regular parameter if needed.
    ///
    /// Supported formats:
    /// 1. Object of arrays (Tealium): `{"param_items_item_id": ["SKU1", "SKU2"], ...}`
    /// 2. Array of objects (Firebase-ready): `[{"item_id": "SKU1"}, {"item_id": "SKU2"}]`
    private func buildItems(from eventParamsData: [String: DataItem]) throws(FirebaseCommandError) -> [[String: Any]]? {
        guard let itemsData = eventParamsData[FirebaseEventParameter.items.value] else {
            return nil
        }
        var items: [[String: Any]] = []
        // Detect format and handle accordingly
        if let arrayOfObjects = itemsData.getDataArray() {
            // Format: [{"item_id": "SKU1"}, {"item_id": "SKU2"}]
            // Already in Firebase array format - validate and map parameter names
            items = buildItemsFromArrayOfObjects(arrayOfObjects)
        } else if let objectOfArrays = itemsData.getDataDictionary() {
            // Format: {"param_items_item_id": ["SKU1", "SKU2"]}
            // Tealium parallel arrays format - needs conversion
            items = try buildItemsFromParallelArrays(objectOfArrays)
        }
        return items.isEmpty ? nil : items
    }
    
    /// Converts array of objects to Firebase items format with parameter name mapping.
    /// Input:  [DataItem(dict: {"item_id": "SKU1"}), DataItem(dict: {"item_id": "SKU2"})]
    /// Output: [["item_id": "SKU1"], ["item_id": "SKU2"]]
    ///
    /// Maps parameter names through `FirebaseItemParameterMapper.map()` to support both:
    /// - Firebase convention: "item_id" → "item_id"
    /// - Tealium convention: "param_items_item_id" → "item_id"
    private func buildItemsFromArrayOfObjects(_ arrayOfObjects: [DataItem]) -> [[String: Any]] {
        return arrayOfObjects.compactMap { itemData in
            guard let itemDict = itemData.getDataDictionary() else {
                return nil
            }
            
            var mappedItem: [String: Any] = [:]
            for (key, value) in itemDict {
                let paramName = FirebaseItemParameterMapper.map(key)
                mappedItem[paramName] = value.toDataInput()
            }
            
            return mappedItem.isEmpty ? nil : mappedItem
        }
    }
    
    /// Converts parallel arrays to array of item dictionaries.
    /// Input:  { "param_items_item_id": ["SKU1", "SKU2"], "param_items_item_name": ["P1", "P2"] }
    /// Output: [["item_id": "SKU1", "item_name": "P1"], ["item_id": "SKU2", "item_name": "P2"]]
    private func buildItemsFromParallelArrays(_ parallelArrays: [String: DataItem]) throws(FirebaseCommandError) -> [[String: Any]] {
        let arrays = extractArrays(from: parallelArrays)
        
        guard let itemCount = arrays.values.map(\.count).max(), itemCount > 0 else {
            return []
        }
        
        // Validate all arrays have the same length
        if let mismatch = arrays.first(where: { $0.value.count != itemCount }),
           let expected = arrays.first(where: { $0.value.count == itemCount }) {
            throw FirebaseCommandError.arrayLengthMismatch(
                array1: expected.key,
                count1: expected.value.count,
                array2: mismatch.key,
                count2: mismatch.value.count
            )
        }
        
        return (0..<itemCount).compactMap { index in
            let item = buildItem(from: arrays, at: index)
            return item.isEmpty ? nil : item
        }
    }
    
    private func buildItem(from arrays: [String: [DataInput]], at index: Int) -> [String: Any] {
        var item: [String: Any] = [:]
        
        for (key, array) in arrays where index < array.count {
            let paramName = FirebaseItemParameterMapper.map(key)
            item[paramName] = array[index]
        }
        
        return item
    }
    
    private func extractArrays(from dict: [String: DataItem]) -> [String: [DataInput]] {
        dict.compactMapValues { $0.getDataArray()?.map { $0.toDataInput() } }
    }
}


