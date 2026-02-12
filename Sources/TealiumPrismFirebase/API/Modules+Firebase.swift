//
//  Tealium+Firebase.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 9/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

public extension Modules {
    
    /**
     * Returns a factory for creating the `FirebaseDispatcher`.
     *
     * Firebase Analytics only supports a single shared instance, so only one `FirebaseDispatcher` can be active at a time.
     * Firebase is configured automatically on first use. If you need to configure Firebase manually
     * (e.g., for Crashlytics), call `FirebaseApp.configure()` before starting Tealium.
     * See the Example app for both initialization approaches.
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
        BasicModuleFactory<FirebaseDispatcher>(
            moduleType: Modules.Types.firebaseDispatcher,
            enforcedSettings: block?(FirebaseSettingsBuilder()).build()
        )
    }
}

public extension Modules.Types {
    /// Module type identifier for Firebase Dispatcher.
    static let firebaseDispatcher = FirebaseConstants.moduleType
}
