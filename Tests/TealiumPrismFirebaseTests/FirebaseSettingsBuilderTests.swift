//
//  FirebaseSettingsBuilderTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 13/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import FirebaseCore
@testable import TealiumPrismCore
@testable import TealiumPrismFirebase
import XCTest

final class FirebaseSettingsBuilderTests: XCTestCase {

    func test_firebaseSettingsBuilder_build_returns_configuration() throws {
        let settings = FirebaseSettingsBuilder()
            .setSessionTimeout(1800.seconds)
            .setAnalyticsEnabled(true)
            .setLogLevel(.debug)
            .build()

        XCTAssertEqual(settings, [
            "configuration": [
                FirebaseDispatcherConfiguration.Keys.sessionTimeout: 1800.0 as Double,
                FirebaseDispatcherConfiguration.Keys.analyticsEnabled: true,
                FirebaseDispatcherConfiguration.Keys.logLevel: "debug"
            ] as DataObject
        ])
    }

    func test_firebaseSettingsBuilder_empty_returns_empty_configuration() {
        let settings = FirebaseSettingsBuilder().build()
        XCTAssertEqual(settings, ["configuration": DataObject()])
    }
}
