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

/// Mock implementation of FirebaseCommandProtocol for testing command execution.
/// Tracks execution calls and can be configured to succeed or throw an error.
class MockCommand: FirebaseCommandProtocol {
    
    let name: String
    let shouldThrow: Bool
    let errorToThrow: Error?
    
    var executeCalled = false
    var lastPayload: DataObject?
    var executeCallCount = 0
    
    init(name: String, shouldThrow: Bool = false, errorToThrow: Error? = nil) {
        self.name = name
        self.shouldThrow = shouldThrow
        self.errorToThrow = errorToThrow
    }
    
    func execute(payload: DataObject) throws {
        executeCalled = true
        lastPayload = payload
        executeCallCount += 1
        
        if shouldThrow {
            throw errorToThrow ?? FirebaseCommandError.missingParameter("test_param")
        }
    }
}
