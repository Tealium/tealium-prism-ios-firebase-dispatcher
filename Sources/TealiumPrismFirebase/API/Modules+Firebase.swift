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
    
    /**
     * Returns a factory for creating the `FirebaseDispatcher`.
     *
     * - parameter block: A block used to provide programmatic settings. See `EnforcingSettings`.
     * Pass `nil` to initialize this module only when some Local or Remote settings are provided.
     * Omitting this parameter will initialize the module with its default settings.
     *
     * Example:
     * ```swift
     * Modules.firebaseDispatcher(forcingSettings: { builder in
     *     builder
     *         .setSessionTimeout(1800)
     *         .setMappings([
     *             .mapFirebaseLogEventCommand(),
     *             .mapFirebaseLogEventName()
     *         ])
     * })
     * ```
     */
    static func firebaseDispatcher(
        forcingSettings block: EnforcingSettings<FirebaseSettingsBuilder>? = { $0 }
    ) -> some ModuleFactory {
        FirebaseDispatcher.Factory(forcingSettings: [block])
    }
    
    /**
     * Returns a factory for creating the `FirebaseDispatcher`.
     *
     * When using this method, be sure to provide different module IDs per each `FirebaseSettingsBuilder` provided.
     * If multiple builders result in having the same module ID, only the first one will be used.
     * Default module ID will be the `Modules.Types.firebaseDispatcher` (`FirebaseDispatcher`).
     *
     * - Parameters:
     *   - block: A block with a utility builder that can be used to enforce some of the `FirebaseDispatcher` settings instead of relying on
     *   Local or Remote settings. Only the settings built with this builder will be enforced and remain constant during the lifecycle of the
     *   `FirebaseDispatcher`, other settings will still be affected by Local and Remote settings and updates.
     *   - blocks: Other blocks used to configure additional Firebase Dispatcher modules.
     *
     * Example:
     * ```swift
     * Modules.firebaseDispatcher(
     *     forcingSettings: { builder in
     *         builder
     *             .setModuleId("firebase_analytics")
     *             .setMappings([.mapFirebaseLogEventCommand()])
     *     },
     *     { builder in
     *         builder
     *             .setModuleId("firebase_crashlytics")
     *             .setMappings([.mapFirebaseUserProperties()])
     *     }
     * )
     * ```
     */
    static func firebaseDispatcher(
        forcingSettings block: @escaping EnforcingSettings<FirebaseSettingsBuilder>,
        _ blocks: EnforcingSettings<FirebaseSettingsBuilder>...
    ) -> some ModuleFactory {
        FirebaseDispatcher.Factory(forcingSettings: [block] + blocks)
    }
}

public extension Modules.Types {
    /// Module type identifier for Firebase Dispatcher.
    static let firebaseDispatcher = FirebaseConstants.moduleType
}
