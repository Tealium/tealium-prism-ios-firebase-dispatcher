//
//  Tealium+Firebase.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 9/01/2026.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

public extension Modules {
    
    /// Returns a factory for creating the Firebase Dispatcher module.
    ///
    /// - Parameter forcingSettings: A block that configures the Firebase Dispatcher settings.
    ///   Only the settings built with this builder will be enforced and remain constant
    ///   during the lifecycle of the `FirebaseDispatcher`. Other settings will still be
    ///   affected by Local and Remote settings and updates.
    ///
    /// - Returns: A module factory for the Firebase Dispatcher.
    ///
    /// ## Example
    ///
    /// ```swift
    /// Modules.firebaseDispatcher(forcingSettings: { builder in
    ///     builder
    ///         .setSessionTimeout(1800)
    ///         .setMappings([
    ///             .mapFirebaseLogEventCommand()
    ///             .mapFirebaseLogEventName()
    ///         ])
    /// })
    /// ```
    static func firebaseDispatcher(
        forcingSettings block: EnforcingSettings<FirebaseSettingsBuilder>? = { $0 }
    ) -> some ModuleFactory {
        let enforcedSettings = block?(FirebaseSettingsBuilder()).build()
        return FirebaseDispatcher.Factory(enforcedSettings: enforcedSettings)
    }
}

public extension Modules.Types {
    /// Module type identifier for Firebase Dispatcher.
    static let firebaseDispatcher = FirebaseConstants.moduleType
}
