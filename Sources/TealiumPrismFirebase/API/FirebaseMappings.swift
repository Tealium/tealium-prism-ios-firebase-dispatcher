//
//  FirebaseMappings.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 5/03/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

// MARK: - Firebase Mappings

/// Concrete Firebase mappings builder combining `FirebaseCommand` and `FirebaseDestination`.
///
/// Used with `FirebaseSettingsBuilder.setMappings(_:)` to configure Firebase-specific
/// data mappings with type-safe enums.
///
/// ```swift
/// Modules.firebaseDispatcher(forcingSettings: { builder in
///     builder.setMappings { mappings in
///         mappings.mapCommand(.logEvent)
///         mappings.mapFrom("tealium_event", to: .eventName)
///         mappings.mapFrom("total", to: .eventParam(AnalyticsParameterValue))
///         mappings.mapFrom("product_ids", to: .itemParam(AnalyticsParameterItemID))
///     }
/// })
/// ```
public class FirebaseMappings: CommandMappingsBuilder<FirebaseCommand, FirebaseDestination> {
    required public init() { super.init() }
}
