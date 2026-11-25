//
//  XCTAssertThrowsExtractionError.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 24/11/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import TealiumPrismCore
import XCTest

/// Asserts that `expression` throws the `expected` `ExtractionError`.
///
/// `ExtractionError` is not `Equatable`, so the errors are compared by their reflected description,
/// which contains the case and its associated values but not the message, so a change to Core's
/// message wording doesn't fail these tests.
func XCTAssertThrowsExtractionError(
    _ expression: @autoclosure () throws -> Void,
    _ expected: ExtractionError,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    XCTAssertThrowsError(try expression(), file: file, line: line) { error in
        guard let extractionError = error as? ExtractionError else {
            XCTFail("Expected \(expected) but got \(error)", file: file, line: line)
            return
        }
        XCTAssertEqual(String(reflecting: extractionError), String(reflecting: expected), file: file, line: line)
    }
}
