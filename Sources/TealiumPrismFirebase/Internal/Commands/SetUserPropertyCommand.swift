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
class SetUserPropertyCommand: FirebaseCommandProtocol {

    private let firebaseInstance: FirebaseAnalyticsInterface

    init(firebaseInstance: FirebaseAnalyticsInterface) {
        self.firebaseInstance = firebaseInstance
    }

    let name = FirebaseCommand.setUserProperty.rawValue

    func execute(payload: DataObject) throws(FirebaseCommandError) {
        let properties = try extractNamesAndValues(payload: payload)

        guard !properties.isEmpty else {
            throw FirebaseCommandError.missingParameter(FirebaseDestination.userPropertyName.path.render())
        }

        // Set each property
        for (name, value) in properties {
            setProperty(name: name, value: value)
        }
    }

    // MARK: - Private Helpers

    /// Extracts property names and values from the payload.
    /// Automatically handles both single values and arrays.
    private func extractNamesAndValues(payload: DataObject) throws(FirebaseCommandError) -> [(name: String, value: String?)] {
        guard let namesItem = payload.extractDataItem(path: FirebaseDestination.userPropertyName.path),
              let valuesItem = payload.extractDataItem(path: FirebaseDestination.userPropertyValue.path) else {
            return []
        }

        // Try to extract as arrays first, fallback to single values
        let namesArray = namesItem.getArray(of: String.self) ?? [namesItem.get(as: String.self)].compactMap { $0 }
        let valuesArray = valuesItem.getArray(of: String.self) ?? [valuesItem.get(as: String.self)]

        guard !namesArray.isEmpty else {
            throw FirebaseCommandError.emptyArray(FirebaseDestination.userPropertyName.path.render())
        }

        guard namesArray.count == valuesArray.count else {
            throw FirebaseCommandError.arrayLengthMismatch(
                array1: FirebaseDestination.userPropertyName.path.render(),
                count1: namesArray.count,
                array2: FirebaseDestination.userPropertyValue.path.render(),
                count2: valuesArray.count
            )
        }

        return zip(namesArray, valuesArray).compactMap { name, value in
            guard let name else {
                return nil
            }
            return (name, value)
        }
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
