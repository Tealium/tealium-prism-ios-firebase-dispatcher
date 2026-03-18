//
//  MockCommand.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 15/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
@testable import TealiumPrismCore
import Foundation

/// Mock implementation of RemoteCommandProtocol for testing command execution.
/// Tracks execution calls and can be configured to succeed or throw an error.
class MockCommand: RemoteCommandProtocol {
    
    let name: String
    let errorToThrow: RemoteCommandError?

    var executeCalled = false
    var lastPayload: DataObject?
    var executeCallCount = 0

    init(name: String, errorToThrow: RemoteCommandError? = nil) {
        self.name = name
        self.errorToThrow = errorToThrow
    }

    func execute(payload: DataObject) throws(RemoteCommandError) {
        executeCalled = true
        lastPayload = payload
        executeCallCount += 1

        if let errorToThrow {
            throw errorToThrow
        }
    }
}
