//
//  FirebaseReadyMechanismTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 9/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import TealiumPrismCore
@testable import TealiumPrismFirebase
import XCTest

/// Tests the onReady mechanism in isolation without requiring real Firebase configuration.
/// This class simulates the same logic as FirebaseInstance but allows control over the "ready" state.
final class FirebaseReadyMechanismTests: XCTestCase {
    
    /// Testable version of the onReady mechanism that doesn't require real Firebase
    class TestableReadyMechanism {
        private let onReadySubject = ReplaySubject<Void>(cacheSize: 1)
        private var isReady = false
        
        /// Simulates Firebase being ready
        func markAsReady() {
            guard !isReady else { return }
            isReady = true
            onReadySubject.publish()
        }
        
        /// Same interface as FirebaseInstance.onReady
        func onReady(_ callback: @escaping () -> Void) {
            onReadySubject.subscribeOnce(callback)
            
            // Check if already ready
            if isReady && onReadySubject.last() == nil {
                onReadySubject.publish()
            }
        }
    }
    
    // MARK: - Tests
    
    func test_onReady_callback_is_called_after_marking_as_ready() async {
        let mechanism = TestableReadyMechanism()
        var callbackExecuted = false
        
        mechanism.onReady {
            callbackExecuted = true
        }
        
        XCTAssertFalse(callbackExecuted, "Callback should not be called yet")
        
        mechanism.markAsReady()
        
        // Give it a moment to process
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
        
        XCTAssertTrue(callbackExecuted, "Callback should be called after marking as ready")
    }
    
    func test_onReady_callback_is_called_immediately_if_already_ready() async {
        let mechanism = TestableReadyMechanism()
        
        // Mark as ready first
        mechanism.markAsReady()
        
        var callbackExecuted = false
        mechanism.onReady {
            callbackExecuted = true
        }
        
        // Give it a moment to process
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
        
        XCTAssertTrue(callbackExecuted, "Callback should be called immediately due to ReplaySubject cache")
    }
    
    func test_multiple_onReady_callbacks_are_all_called() async {
        let mechanism = TestableReadyMechanism()
        var firstCallbackExecuted = false
        var secondCallbackExecuted = false
        var thirdCallbackExecuted = false
        
        mechanism.onReady {
            firstCallbackExecuted = true
        }
        
        mechanism.onReady {
            secondCallbackExecuted = true
        }
        
        mechanism.onReady {
            thirdCallbackExecuted = true
        }
        
        mechanism.markAsReady()
        
        // Give it a moment to process
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
        
        XCTAssertTrue(firstCallbackExecuted, "First callback should be called")
        XCTAssertTrue(secondCallbackExecuted, "Second callback should be called")
        XCTAssertTrue(thirdCallbackExecuted, "Third callback should be called")
    }
    
    func test_late_subscribers_receive_cached_ready_event() async {
        let mechanism = TestableReadyMechanism()
        var earlyCallbackExecuted = false
        var lateCallbackExecuted = false
        
        // Early subscriber
        mechanism.onReady {
            earlyCallbackExecuted = true
        }
        
        mechanism.markAsReady()
        
        // Give it a moment to process
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
        
        XCTAssertTrue(earlyCallbackExecuted, "Early callback should be called")
        
        // Late subscriber - added after ready state
        mechanism.onReady {
            lateCallbackExecuted = true
        }
        
        // Give it a moment to process
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
        
        XCTAssertTrue(lateCallbackExecuted, "Late callback should still be called due to ReplaySubject cache")
    }
    
    func test_marking_as_ready_multiple_times_only_publishes_once() async {
        let mechanism = TestableReadyMechanism()
        var callbackExecutionCount = 0
        
        mechanism.onReady {
            callbackExecutionCount += 1
        }
        
        mechanism.markAsReady()
        mechanism.markAsReady() // Should be ignored
        mechanism.markAsReady() // Should be ignored
        
        // Give it a moment to process
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
        
        XCTAssertEqual(callbackExecutionCount, 1, "Callback should only be called once even if marked ready multiple times")
    }
    
    func test_callbacks_added_rapidly_are_all_executed() async {
        let mechanism = TestableReadyMechanism()
        var executionCount = 0
        let expectedCount = 10
        
        // Add multiple callbacks rapidly
        for _ in 0..<expectedCount {
            mechanism.onReady {
                executionCount += 1
            }
        }
        
        mechanism.markAsReady()
        
        // Give it a moment to process
        try? await Task.sleep(nanoseconds: 20_000_000) // 20ms
        
        XCTAssertEqual(executionCount, expectedCount, "All \(expectedCount) callbacks should be executed")
    }
    
    func test_callback_added_before_and_after_ready_both_execute() async {
        let mechanism = TestableReadyMechanism()
        var beforeReadyExecuted = false
        var afterReadyExecuted = false
        
        // Before ready
        mechanism.onReady {
            beforeReadyExecuted = true
        }
        
        mechanism.markAsReady()
        
        // Give it a moment to process
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
        
        XCTAssertTrue(beforeReadyExecuted, "Before-ready callback should execute")
        
        // After ready
        mechanism.onReady {
            afterReadyExecuted = true
        }
        
        // Give it a moment to process
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
        
        XCTAssertTrue(afterReadyExecuted, "After-ready callback should execute due to cache")
    }
}
