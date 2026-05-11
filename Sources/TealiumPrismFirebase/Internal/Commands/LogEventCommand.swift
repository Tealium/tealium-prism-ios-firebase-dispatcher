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
/// ### Format 1: Object of Arrays (Tealium convention - most common)
/// ```
/// payload = [
///     "command_name": "logevent",
///     "event_name": "purchase",
///     "parameters": [
///         "value": 99.99,
///         "currency": "USD",
///         "items": [
///             "item_id": ["SKU001", "SKU002"],
///             "item_name": ["Widget", "Gadget"],
///             "price": [29.99, 70.00]
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
///         "value": 99.99,
///         "currency": "USD",
///         "items": [
///             ["item_id": "SKU001", "item_name": "Widget", "price": 29.99],
///             ["item_id": "SKU002", "item_name": "Gadget", "price": 70.00]
///         ]
///     ]
/// ]
/// ```
class LogEventCommand: SyncCommand {

    private let firebaseInstance: FirebaseAnalyticsInterface

    init(firebaseInstance: FirebaseAnalyticsInterface) {
        self.firebaseInstance = firebaseInstance
        super.init(name: FirebaseCommand.logEvent.commandName)
    }

    override func execute(payload: DataObject) throws(CommandError) {
        let eventName = try extractEventName(from: payload)
        let parameters = try buildParameters(from: payload)
        firebaseInstance.logEvent(eventName, parameters: parameters.isEmpty ? nil : parameters)
    }

    private func extractEventName(from payload: DataObject) throws(CommandError) -> String {
        guard let rawEventName = payload.extractConvertible(path: FirebaseDestination.eventName.path, converter: LenientConverters.string) else {
            throw CommandError.missingParameter(FirebaseDestination.eventName.path.render())
        }
        
        return rawEventName
    }
    
    /// Builds all Firebase parameters from payload (including items).
    /// - Throws: `CommandError.arrayLengthMismatch` if item arrays have mismatched lengths.
    private func buildParameters(from payload: DataObject) throws(CommandError) -> [String: Any] {
        guard let eventParamsData = payload.extractDataDictionary(path: FirebaseDestination.eventParams.path) else {
            return [:]
        }

        var parameters: [String: Any] = [:]

        if let itemsData = eventParamsData[AnalyticsParameterItems],
           let items = try ItemsBuilder.build(from: itemsData) {
            parameters[AnalyticsParameterItems] = items
        }

        for (key, dataItem) in eventParamsData where key != AnalyticsParameterItems {
            parameters[key] = dataItem.toDataInput()
        }

        return parameters
    }
}


