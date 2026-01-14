//
//  ResetDataCommandTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 14/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
@testable import TealiumPrismCore
import XCTest

final class ResetDataCommandTests: XCTestCase {
    
    var mockFirebase: MockFirebaseCommand!
    var mockLogger: MockLogger!
    var command: ResetDataCommand!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebaseCommand()
        mockLogger = MockLogger()
        command = ResetDataCommand(firebaseInstance: mockFirebase, logger: mockLogger)
    }
    
    override func tearDown() {
        command = nil
        mockFirebase = nil
        mockLogger = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func test_execute_calls_reset_analytics_data() {
        let payload: DataObject = [:]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.resetAnalyticsDataCalled)
    }
    
    func test_execute_always_returns_true() {
        let payload: DataObject = ["some": "data"]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
    }
}
