//
//  SetDefaultParametersCommand.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 10/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

/// Command for setting default event parameters in Firebase Analytics.
///
/// Default parameters are automatically included with every event logged to Firebase.
/// These parameters persist across app runs and are of lower precedence than event parameters.
/// Missing payload (nil) clears all default parameters.
///
/// Firebase SDK Reference:
/// - https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setdefaulteventparameters_:
///
/// ## Expected Payload
///
/// ```
/// payload = [
///     "command_name": "setdefaultparameters",
///     "parameters": [
///         "version": "2.1.0",
///         "language": "en",
///         "country": "US"
///     ]
/// ]
/// ```
class SetDefaultParametersCommand: SyncCommand {

    private let firebaseInstance: FirebaseAnalyticsInterface

    init(firebaseInstance: FirebaseAnalyticsInterface) {
        self.firebaseInstance = firebaseInstance
        super.init(name: FirebaseCommand.setDefaultParameters.rawValue)
    }

    override func execute(payload: DataObject) throws(CommandError) {
        // parameters is missing -> clear all default parameters
        guard let defaultParamsData = payload.extractDataDictionary(path: FirebaseDestination.defaultParams.path) else {
            firebaseInstance.setDefaultEventParameters(nil)
            return
        }
        
        let defaultParams = defaultParamsData.mapValues { $0.toDataInput() }
        
        firebaseInstance.setDefaultEventParameters(defaultParams)
    }
}

