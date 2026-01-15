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
/// Tracks execution calls and can be configured to succeed or fail.
class MockCommand: FirebaseCommandProtocol {
    
    let name: String
    let returnValue: Bool
    
    var executeCalled = false
    var lastPayload: DataObject?
    var executeCallCount = 0
    
    init(name: String, returnValue: Bool = true) {
        self.name = name
        self.returnValue = returnValue
    }
    
    func execute(payload: DataObject) -> Bool {
        executeCalled = true
        lastPayload = payload
        executeCallCount += 1
        return returnValue
    }
}
