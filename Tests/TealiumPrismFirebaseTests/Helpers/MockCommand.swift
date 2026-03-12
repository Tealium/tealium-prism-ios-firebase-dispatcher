//
//  MockCommand.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 15/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation
@testable import TealiumPrismCore
@testable import TealiumPrismFirebase

/// Mock implementation of FirebaseCommandProtocol for testing command execution.
/// Tracks execution calls and can be configured to succeed or throw an error.
class MockCommand: FirebaseCommandProtocol {

    let name: String
    let errorToThrow: FirebaseCommandError?

    var executeCalled = false
    var lastPayload: DataObject?
    var executeCallCount = 0

    init(name: String, errorToThrow: FirebaseCommandError? = nil) {
        self.name = name
        self.errorToThrow = errorToThrow
    }

    func execute(payload: DataObject) throws(FirebaseCommandError) {
        executeCalled = true
        lastPayload = payload
        executeCallCount += 1

        if let errorToThrow {
            throw errorToThrow
        }
    }
}
