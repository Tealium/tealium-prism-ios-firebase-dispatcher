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

/// Mock implementation of CommandProtocol for testing command execution.
/// Tracks execution calls and can be configured to succeed or throw an error.
class MockCommand: CommandProtocol {
    
    let name: String
    let errorToThrow: CommandError?

    var executeCalled = false
    var lastPayload: DataObject?
    var executeCallCount = 0

    init(name: String, errorToThrow: CommandError? = nil) {
        self.name = name
        self.errorToThrow = errorToThrow
    }

    func execute(payload: DataObject) throws(CommandError) {
        executeCalled = true
        lastPayload = payload
        executeCallCount += 1

        if let errorToThrow {
            throw errorToThrow
        }
    }
}
