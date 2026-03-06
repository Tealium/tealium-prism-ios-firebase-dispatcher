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

    /// Maps a dispatch using FirebaseMappings configured via a closure
    func map(dispatch: Dispatch, setup: (FirebaseMappings) -> Void) -> Dispatch {
        let mappings = FirebaseMappings()
        setup(mappings)
        return engine.map(dispatch: dispatch, mappings: mappings.build())
    }
}
