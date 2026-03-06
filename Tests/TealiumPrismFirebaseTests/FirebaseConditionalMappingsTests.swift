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

        let result = map(dispatch: dispatch) { mappings in
            mappings.mapCommand(.logEvent)
                .ifValueIn(TealiumDataKey.event, equals: "screen_view")
            mappings.mapFrom(TealiumDataKey.event, to: .eventName)
        }

        // Command should be added because tealium_event == "screen_view"
        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseCommand.logEvent.rawValue,
            FirebaseDestination.eventName.renderedPath: "screen_view"
        ])
    }

    func test_conditional_command_with_ifValueIn_does_not_match() {
        let dispatch = Dispatch(name: "purchase", type: .event)

        let result = map(dispatch: dispatch) { mappings in
            mappings.mapCommand(.logEvent)
                .ifValueIn(TealiumDataKey.event, equals: "screen_view")
            mappings.mapFrom(TealiumDataKey.event, to: .eventName)
        }

        // Command should NOT be added because tealium_event != "screen_view"
        // But event name should still be mapped
        XCTAssertEqual(result.payload, [
            FirebaseDestination.eventName.renderedPath: "purchase"
        ])
    }

    func test_conditional_eventName_with_ifValueEquals_matches() {
        let dispatch = Dispatch(name: "screen_view", type: .event)

        let result = map(dispatch: dispatch) { mappings in
            mappings.mapCommand(.logEvent)
            mappings.mapFrom(TealiumDataKey.event, to: .eventName)
                .ifValueEquals("screen_view")
        }

        // Both command and event name should be added
        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseCommand.logEvent.rawValue,
            FirebaseDestination.eventName.renderedPath: "screen_view"
        ])
    }

    func test_conditional_eventName_with_ifValueEquals_does_not_match() {
        let dispatch = Dispatch(name: "purchase", type: .event)

        let result = map(dispatch: dispatch) { mappings in
            mappings.mapCommand(.logEvent)
            mappings.mapFrom(TealiumDataKey.event, to: .eventName)
                .ifValueEquals("screen_view")
        }

        // Command should be added, but event name should NOT be mapped
        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseCommand.logEvent.rawValue
        ])
    }

    func test_multiple_commands_without_conditions() {
        let dispatch = Dispatch(name: "login", type: .event, data: [
            "customer_id": "USER_123"
        ])

        let result = map(dispatch: dispatch) { mappings in
            // Add both logevent and setuserid commands
            mappings.mapCommand(.logEvent)
            mappings.mapFrom(TealiumDataKey.event, to: .eventName)
            mappings.mapCommand(.setUserId)
            mappings.mapFrom("customer_id", to: .userId)
        }

        // Both commands should be in payload
        // When multiple commands are added to the same key, they are combined into an array
        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: [
                FirebaseCommand.logEvent.rawValue,
                FirebaseCommand.setUserId.rawValue
            ],
            FirebaseDestination.eventName.renderedPath: "login",
            FirebaseDestination.userId.renderedPath: "USER_123"
        ])
    }

    func test_conditional_with_custom_event_key() {
        let dispatch = Dispatch(name: "page_view", type: .event, data: [
            "custom_event": "special_screen"
        ])

        let result = map(dispatch: dispatch) { mappings in
            mappings.mapCommand(.logEvent)
                .ifValueIn("custom_event", equals: "special_screen")
            mappings.mapFrom("custom_event", to: .eventName)
        }

        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseCommand.logEvent.rawValue,
            FirebaseDestination.eventName.renderedPath: "special_screen"
        ])
    }
}
