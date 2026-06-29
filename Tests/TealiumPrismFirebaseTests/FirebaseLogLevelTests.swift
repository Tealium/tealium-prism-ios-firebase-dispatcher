//
//  FirebaseLogLevelTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 29/06/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import FirebaseCore
import XCTest

@testable import TealiumPrismFirebase

final class FirebaseLogLevelTests: XCTestCase {

    // MARK: - fromString Tests

    func test_fromString_returns_correct_level_for_all_cases() {
        XCTAssertEqual(FirebaseLogLevel.fromString("min"), .min)
        XCTAssertEqual(FirebaseLogLevel.fromString("error"), .error)
        XCTAssertEqual(FirebaseLogLevel.fromString("warning"), .warning)
        XCTAssertEqual(FirebaseLogLevel.fromString("notice"), .notice)
        XCTAssertEqual(FirebaseLogLevel.fromString("info"), .info)
        XCTAssertEqual(FirebaseLogLevel.fromString("debug"), .debug)
        XCTAssertEqual(FirebaseLogLevel.fromString("max"), .max)
    }

    func test_fromString_is_case_insensitive() {
        XCTAssertEqual(FirebaseLogLevel.fromString("MIN"), .min)
        XCTAssertEqual(FirebaseLogLevel.fromString("WARNING"), .warning)
        XCTAssertEqual(FirebaseLogLevel.fromString("Debug"), .debug)
    }

    func test_fromString_returns_nil_for_unknown_string() {
        XCTAssertNil(FirebaseLogLevel.fromString("verbose"))
        XCTAssertNil(FirebaseLogLevel.fromString(""))
    }

    // MARK: - init(firebaseLoggerLevel:) Tests

    func test_init_min_maps_to_error() {
        XCTAssertEqual(FirebaseLogLevel(firebaseLoggerLevel: .min), .error)
    }

    func test_init_error_maps_to_error() {
        XCTAssertEqual(FirebaseLogLevel(firebaseLoggerLevel: .error), .error)
    }

    func test_init_max_maps_to_debug() {
        XCTAssertEqual(FirebaseLogLevel(firebaseLoggerLevel: .max), .debug)
    }

    func test_init_debug_maps_to_debug() {
        XCTAssertEqual(FirebaseLogLevel(firebaseLoggerLevel: .debug), .debug)
    }

    func test_init_warning_maps_to_warning() {
        XCTAssertEqual(FirebaseLogLevel(firebaseLoggerLevel: .warning), .warning)
    }

    func test_init_notice_maps_to_notice() {
        XCTAssertEqual(FirebaseLogLevel(firebaseLoggerLevel: .notice), .notice)
    }

    func test_init_info_maps_to_info() {
        XCTAssertEqual(FirebaseLogLevel(firebaseLoggerLevel: .info), .info)
    }

    // MARK: - toString Tests

    func test_toString_for_all_firebase_logger_levels() {
        // .min and .max collapse to .error and .debug respectively (Firebase SDK aliasing).
        XCTAssertEqual(FirebaseLogLevel.toString(.min), "error")
        XCTAssertEqual(FirebaseLogLevel.toString(.error), "error")
        XCTAssertEqual(FirebaseLogLevel.toString(.warning), "warning")
        XCTAssertEqual(FirebaseLogLevel.toString(.notice), "notice")
        XCTAssertEqual(FirebaseLogLevel.toString(.info), "info")
        XCTAssertEqual(FirebaseLogLevel.toString(.debug), "debug")
        XCTAssertEqual(FirebaseLogLevel.toString(.max), "debug")
    }

    // MARK: - value Tests

    func test_value_returns_correct_firebase_logger_level_for_all_cases() {
        XCTAssertEqual(FirebaseLogLevel.min.value, .min)
        XCTAssertEqual(FirebaseLogLevel.error.value, .error)
        XCTAssertEqual(FirebaseLogLevel.warning.value, .warning)
        XCTAssertEqual(FirebaseLogLevel.notice.value, .notice)
        XCTAssertEqual(FirebaseLogLevel.info.value, .info)
        XCTAssertEqual(FirebaseLogLevel.debug.value, .debug)
        XCTAssertEqual(FirebaseLogLevel.max.value, .max)
    }
}
