//
//  ReferenceContainerConvertible.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 5/03/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

/// Protocol for converting type-safe enum values to a `ReferenceContainer`.
///
/// Used by `RemoteCommandMappingsBuilder` to allow vendor-specific enums
/// (like `FirebaseDestination`) as mapping destinations.
public protocol ReferenceContainerConvertible {
    func asReferenceContainer() -> ReferenceContainer
}
