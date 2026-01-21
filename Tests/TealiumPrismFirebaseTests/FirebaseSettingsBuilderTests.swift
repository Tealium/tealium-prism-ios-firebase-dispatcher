//
//  FirebaseSettingsBuilderTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 13/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
@testable import TealiumPrismCore
import XCTest

final class FirebaseSettingsBuilderTests: XCTestCase {
    
    func test_firebaseSettingsBuilder_build_returns_configuration() throws {
        let settings = FirebaseSettingsBuilder()
            .setSessionTimeout(1800)
            .setAnalyticsEnabled(true)
            .setLogLevel("debug")
            .build()
        
        XCTAssertEqual(settings, [
            "configuration": try DataItem(serializing: [
                FirebaseConstants.Initialize.Param.sessionTimeout: 1800 as Int,
                FirebaseConstants.Initialize.Param.analyticsEnabled: true,
                FirebaseConstants.Initialize.Param.logLevel: "debug"
            ])
        ])
    }
    
    func test_firebaseSettingsBuilder_empty_returns_empty_configuration() {
        let settings = FirebaseSettingsBuilder().build()
        XCTAssertEqual(settings, ["configuration": DataObject()])
    }
}
