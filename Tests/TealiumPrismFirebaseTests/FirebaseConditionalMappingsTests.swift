//
//  FirebaseConditionalMappingsTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 13/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
@testable import TealiumPrismCore
import XCTest

/// Tests for conditional mappings using ifValueIn and ifValueEquals
final class FirebaseConditionalMappingsTests: FirebaseMappingsTestBase {
    
    func test_conditional_command_with_ifValueIn_matches() {
        let dispatch = Dispatch(name: "screen_view", type: .event)
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseLogEventCommand()
                .ifValueIn(TealiumDataKey.event, equals: "screen_view"),
            .mapFirebaseLogEventName()
        ])
        
        // Command should be added because tealium_event == "screen_view"
        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandKey: FirebaseConstants.LogEvent.name,
            FirebaseConstants.LogEvent.Param.eventName: "screen_view"
        ])
    }
    
    func test_conditional_command_with_ifValueIn_does_not_match() {
        let dispatch = Dispatch(name: "purchase", type: .event)
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseLogEventCommand()
                .ifValueIn(TealiumDataKey.event, equals: "screen_view"),
            .mapFirebaseLogEventName()
        ])
        
        // Command should NOT be added because tealium_event != "screen_view"
        // But event name should still be mapped
        XCTAssertEqual(result.payload, [
            FirebaseConstants.LogEvent.Param.eventName: "purchase"
        ])
    }
    
    func test_conditional_eventName_with_ifValueEquals_matches() {
        let dispatch = Dispatch(name: "screen_view", type: .event)
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseLogEventCommand(),
            .mapFirebaseLogEventName()
                .ifValueEquals("screen_view")
        ])
        
        // Both command and event name should be added
        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandKey: FirebaseConstants.LogEvent.name,
            FirebaseConstants.LogEvent.Param.eventName: "screen_view"
        ])
    }
    
    func test_conditional_eventName_with_ifValueEquals_does_not_match() {
        let dispatch = Dispatch(name: "purchase", type: .event)
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseLogEventCommand(),
            .mapFirebaseLogEventName()
                .ifValueEquals("screen_view")
        ])
        
        // Command should be added, but event name should NOT be mapped
        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandKey: FirebaseConstants.LogEvent.name
        ])
    }
    
    func test_multiple_commands_without_conditions() {
        let dispatch = Dispatch(name: "login", type: .event, data: [
            "customer_id": "USER_123"
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            // Add both logevent and setuserid commands
            .mapFirebaseLogEventCommand(),
            .mapFirebaseLogEventName(),
            .mapFirebaseSetUserIdCommand(),
            .mapFirebaseUserId(userIdKey: "customer_id")
        ])
        
        // Both commands should be in payload
        // When multiple commands are added to the same key, they are combined into an array
        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandKey: [
                FirebaseConstants.LogEvent.name,
                FirebaseConstants.SetUserId.name
            ],
            FirebaseConstants.LogEvent.Param.eventName: "login",
            FirebaseConstants.SetUserId.Param.userId: "USER_123"
        ])
    }
    
    func test_conditional_with_custom_event_key() {
        let dispatch = Dispatch(name: "page_view", type: .event, data: [
            "custom_event": "special_screen"
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseLogEventCommand()
                .ifValueIn("custom_event", equals: "special_screen"),
            .mapFirebaseLogEventName(eventKey: "custom_event")
        ])
        
        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandKey: FirebaseConstants.LogEvent.name,
            FirebaseConstants.LogEvent.Param.eventName: "special_screen"
        ])
    }
}
