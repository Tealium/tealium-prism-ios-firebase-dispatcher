//
//  FirebaseMappingsTestHelpers.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 13/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
@testable import TealiumPrismCore
import XCTest

/// Base test class with common helpers for Firebase mappings tests
class FirebaseMappingsTestBase: XCTestCase {
    
    @StateSubject([:])
    var mappingsState: ObservableState<[String: [MappingOperation]]>
    lazy var engine = MappingsEngine(mappings: mappingsState)
    
    /// Maps a dispatch using the provided mappings and returns the result
    func map(dispatch: Dispatch, mappings: [Mappings]) -> Dispatch {
        engine.map(dispatch: dispatch, mappings: mappings.map { $0.build() })
    }
}
