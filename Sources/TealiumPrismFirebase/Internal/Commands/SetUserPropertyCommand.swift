//
//  SetUserPropertyCommand.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 10/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

/// Command for setting Firebase Analytics user property(ies).
///
/// Sets one or multiple user properties. Up to 25 user property names are supported.
/// Once set, user property values persist throughout the app lifecycle and across sessions.
/// Empty string removes the property.
///
/// This command automatically detects whether the input is a single property or multiple properties:
/// - Single values: `property_name` and `property_value` as strings
/// - Multiple values: `property_name` and `property_value` as arrays
///
/// Firebase SDK Reference:
/// - https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setuserproperty_:forname:
///
/// ## Expected Payload
///
/// Single property:
/// ```
/// payload = [
///     "command_name": "setuserproperty",
///     "property_name": "tier",
///     "property_value": "premium"  // Empty string removes property
/// ]
/// ```
///
/// Multiple properties (arrays):
/// ```
/// payload = [
///     "command_name": "setuserproperty",
///     "property_name": ["subscription_tier", "user_level"],
///     "property_value": ["premium", "expert"]
/// ]
/// ```
class SetUserPropertyCommand: SyncCommand {

    private let firebaseInstance: FirebaseAnalyticsInterface

    init(firebaseInstance: FirebaseAnalyticsInterface) {
        self.firebaseInstance = firebaseInstance
        super.init(name: FirebaseCommand.setUserProperty.commandName)
    }

    override func execute(payload: DataObject) throws(CommandError) {
        let properties = try extractNamesAndValues(payload: payload)
        for (name, value) in properties {
            setProperty(name: name, value: value)
        }
    }

    // MARK: - Private Helpers

    private func extractNamesAndValues(payload: DataObject) throws(CommandError) -> [(
        name: String, value: String?
    )] {
        guard
            let namesItem = payload.extractDataItem(path: FirebaseDestination.userPropertyName.path)
        else {
            throw CommandError.missingParameter(FirebaseDestination.userPropertyName.path.render())
        }
        guard
            let valuesItem = payload.extractDataItem(
                path: FirebaseDestination.userPropertyValue.path)
        else {
            throw CommandError.missingParameter(FirebaseDestination.userPropertyValue.path.render())
        }

        let namesArray =
            namesItem.getArray(of: String.self)
            ?? [namesItem.getConvertible(converter: LenientConverters.string)].compactMap { $0 }
        let valuesArray =
            valuesItem.getArray(of: String.self) ?? [
                valuesItem.getConvertible(converter: LenientConverters.string)
            ]

        guard !namesArray.isEmpty else {
            throw CommandError.emptyArray(FirebaseDestination.userPropertyName.path.render())
        }

        guard namesArray.count == valuesArray.count else {
            throw CommandError.arrayLengthMismatch(
                array1: FirebaseDestination.userPropertyName.path.render(),
                count1: namesArray.count,
                array2: FirebaseDestination.userPropertyValue.path.render(),
                count2: valuesArray.count
            )
        }

        let properties = zip(namesArray, valuesArray).compactMap {
            name, value -> (name: String, value: String?)? in
            guard let name else {
                return nil
            }
            return (name, value)
        }

        guard !properties.isEmpty else {
            throw CommandError.emptyArray(FirebaseDestination.userPropertyName.path.render())
        }

        return properties
    }

    private func setProperty(name: String, value: String?) {
        // Empty string or nil removes the property
        if let value, !value.isEmpty {
            firebaseInstance.setUserProperty(value, forName: name)
        } else {
            firebaseInstance.setUserProperty(nil, forName: name)
        }
    }
}
