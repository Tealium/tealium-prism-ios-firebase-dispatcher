//
//  XCTestCase+WaitForDefaultTimeout.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 15/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import XCTest

extension XCTestCase {
    
    static let defaultTimeout: TimeInterval = 0.1
    
    func waitForDefaultTimeout() {
        waitForExpectations(timeout: Self.defaultTimeout)
    }
    
    static let longTimeout: TimeInterval = 10
    
    func waitForLongTimeout() {
        waitForExpectations(timeout: Self.longTimeout)
    }
}
