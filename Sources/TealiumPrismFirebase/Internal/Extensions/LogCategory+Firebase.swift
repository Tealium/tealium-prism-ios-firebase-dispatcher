//
//  LogCategory+Firebase.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 9/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation
#if canImport(TealiumPrismCore)
import TealiumPrismCore
#else
import TealiumPrism
#endif

/// Extension for TealiumPrismCore LogCategory to add Firebase category.
extension LogCategory {
    static let firebase = "Firebase"
}
