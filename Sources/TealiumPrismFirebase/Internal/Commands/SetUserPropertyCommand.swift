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
/// Sets one or multiple user properties.
/// Once set, user property values persist throughout the app lifecycle and across sessions.
/// Empty string removes the property.
///
/// Every resolved name/value pair is forwarded to the SDK as-is. Firebase enforces its own quotas
/// on property names and values; this command does not duplicate them.
///
/// This command automatically detects whether the input is a single property or multiple properties:
/// - Single values: `property_name` and `property_value` as strings
/// - Multiple values: `property_name` and `property_value` as arrays
///
/// Names and values are read leniently, so numbers and booleans become strings.
///
/// The payload is checked in this order:
/// 1. `property_name` must be a value that can be read as a string, or an array;
///    otherwise the command fails with a type mismatch.
/// 2. `property_name` and `property_value` must have the same length (a single value counts as one).
/// 3. At least one name must be usable. Array entries that cannot be read as a string are skipped.
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

    override func execute(payload: DataObject) throws {
        let namesDestination = FirebaseDestination.userPropertyName
        let valuesDestination = FirebaseDestination.userPropertyValue

        guard let names = try payload.requireDataItem(namesDestination).toStrings() else {
            throw ExtractionError.typeMismatch(key: namesDestination.path.render(), expectedType: "String or array of String")
        }
        // A value that can't be read as a string clears the property, like an explicit null.
        let values = try payload.requireDataItem(valuesDestination).toStrings() ?? [nil]

        guard names.count == values.count else {
            throw CommandError.arrayLengthMismatch(
                array1: namesDestination.path.render(),
                count1: names.count,
                array2: valuesDestination.path.render(),
                count2: values.count
            )
        }
        guard names.contains(where: { $0 != nil }) else {
            throw ExtractionError.empty(key: namesDestination.path.render())
        }

        for (name, value) in zip(names, values) {
            guard let name else {
                continue
            }
            setProperty(name: name, value: value)
        }
    }

    // MARK: - Private Helpers

    private func setProperty(name: String, value: String?) {
        // Empty string or nil removes the property
        if let value, !value.isEmpty {
            firebaseInstance.setUserProperty(value, forName: name)
        } else {
            firebaseInstance.setUserProperty(nil, forName: name)
        }
    }
}

private extension DataItem {
    /// Reads this payload item as a list of strings, accepting either a single value or an array.
    ///
    /// Every value is read with ``LenientConverters/string``. An array entry that can't be read as a string,
    /// and an explicit `null`, become `nil`.
    ///
    /// - returns: The strings, or `nil` if this item is neither an array, `null`, nor a value that can be read as a string.
    func toStrings() -> [String?]? {
        if let array = getDataArray() {
            return array.map { $0.getConvertible(converter: LenientConverters.string) }
        }
        if get(as: NSNull.self) != nil {
            return [nil]
        }
        return getConvertible(converter: LenientConverters.string).map { [$0] }
    }
}
