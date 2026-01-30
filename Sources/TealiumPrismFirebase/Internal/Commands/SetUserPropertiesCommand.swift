//
//  SetUserPropertiesCommand.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 10/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

/// Command for setting multiple Firebase Analytics user properties at once.
///
/// Sets multiple user properties using parallel arrays. Up to 25 user property names are supported.
/// Once set, user property values persist throughout the app lifecycle and across sessions.
///
/// Firebase SDK Reference:
/// - https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setuserproperty_:forname:
///
/// ## Expected Payload
///
/// ```
/// payload = [
///     "command": "setuserproperties",
///     "firebase_property_names": ["subscription_tier", "user_level", "account_type"],
///     "firebase_property_values": ["premium", "expert", "business"]
/// ]
/// ```
class SetUserPropertiesCommand: FirebaseCommandProtocol {
    
    private let firebaseInstance: FirebaseCommand
    
    init(firebaseInstance: FirebaseCommand) {
        self.firebaseInstance = firebaseInstance
    }
    
    let name = FirebaseConstants.SetUserProperties.name
    typealias Param = FirebaseConstants.SetUserProperties.Param
    
    func execute(payload: DataObject) throws {
        guard let names = payload.getArray(key: Param.propertyNames, of: String.self)?.compactMap({ $0 }) else {
            throw FirebaseCommandError.invalidParameterType(
                parameter: Param.propertyNames,
                expectedType: "array of strings"
            )
        }
        
        guard let values = payload.getArray(key: Param.propertyValues, of: String.self)?.compactMap({ $0 }) else {
            throw FirebaseCommandError.invalidParameterType(
                parameter: Param.propertyValues,
                expectedType: "array of strings"
            )
        }
        
        guard !names.isEmpty else {
            throw FirebaseCommandError.emptyArray(Param.propertyNames)
        }
        
        guard names.count == values.count else {
            throw FirebaseCommandError.arrayLengthMismatch(
                array1: Param.propertyNames,
                count1: names.count,
                array2: Param.propertyValues,
                count2: values.count
            )
        }
        
        // Set each property (continues even if some fail validation)
        for (index, name) in names.enumerated() {
            let value = values[index]
            setProperty(name: name, value: value)
        }
    }
    
    // MARK: - Private Helpers
    
    private func setProperty(name: String, value: String?) {
        // Empty string or nil removes the property
        if let value = value, !value.isEmpty {
            firebaseInstance.setUserProperty(value, forName: name)
        } else {
            firebaseInstance.setUserProperty(nil, forName: name)
        }
    }
}

