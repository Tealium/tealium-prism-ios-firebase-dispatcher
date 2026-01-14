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
            .setGA360Mode(false)
            .setLogLevel("debug")
            .setInvalidCharacterStrategy("replace")
            .build()
        
        XCTAssertEqual(settings, [
            "configuration": try DataItem(serializing: [
                "firebase_session_timeout_seconds": 1800 as Int,
                "firebase_analytics_collection_enabled": true,
                "firebase_ga360_mode": false,
                "firebase_log_level": "debug",
                "firebase_invalid_char_strategy": "replace"
            ])
        ])
    }
    
    func test_firebaseSettingsBuilder_empty_returns_empty_configuration() {
        let settings = FirebaseSettingsBuilder().build()
        XCTAssertEqual(settings, ["configuration": DataObject()])
    }
}
