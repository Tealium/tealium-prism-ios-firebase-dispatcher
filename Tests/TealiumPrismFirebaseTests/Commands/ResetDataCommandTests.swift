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
    
    let mockFirebase = MockFirebaseAnalytics()
    lazy var command = ResetDataCommand(firebaseInstance: mockFirebase)

    // MARK: - Tests
    
    func test_execute_calls_reset_analytics_data() {
        let payload: DataObject = [:]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.resetAnalyticsDataCalled)
    }
}
