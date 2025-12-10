//
//  FirebaseValidatorTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 9/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
import XCTest

final class FirebaseValidatorTests: XCTestCase {
    
    // MARK: - Event Name Tests
    
    func test_valid_event_name_passes_validation() {
        let validator = FirebaseValidator()
        XCTAssertEqual(validator.validateEventName("purchase"), "purchase")
    }
    
    func test_empty_event_name_returns_nil() {
        let validator = FirebaseValidator()
        XCTAssertNil(validator.validateEventName(""))
        XCTAssertNil(validator.validateEventName("   "))
    }
    
    func test_reserved_event_names_return_nil() {
        let validator = FirebaseValidator()
        XCTAssertNil(validator.validateEventName("session_start"))
        XCTAssertNil(validator.validateEventName("first_open"))
    }
    
    func test_reserved_prefixes_are_removed_from_event_names() {
        let validator = FirebaseValidator()
        XCTAssertEqual(validator.validateEventName("firebase_custom"), "custom")
        XCTAssertEqual(validator.validateEventName("google_custom"), "custom")
        XCTAssertEqual(validator.validateEventName("ga_custom"), "custom")
    }
    
    func test_event_name_that_is_only_reserved_prefix_returns_nil() {
        let validator = FirebaseValidator()
        XCTAssertNil(validator.validateEventName("firebase_"))
        XCTAssertNil(validator.validateEventName("google_"))
        XCTAssertNil(validator.validateEventName("ga_"))
    }
    
    func test_event_name_starting_with_number_gets_prefix() {
        let validator = FirebaseValidator()
        XCTAssertEqual(validator.validateEventName("123event"), "event_123event")
    }
    
    func test_event_name_with_invalid_chars_uses_replace_strategy() {
        let validator = FirebaseValidator()
        validator.setInvalidCharStrategy(FirebaseValidator.Validation.Strategy.replace)
        XCTAssertEqual(validator.validateEventName("my-event.name"), "my_event_name")
        XCTAssertEqual(validator.validateEventName("test@event#123"), "test_event_123")
    }
    
    func test_event_name_with_invalid_chars_uses_remove_strategy() {
        let validator = FirebaseValidator()
        validator.setInvalidCharStrategy(FirebaseValidator.Validation.Strategy.remove)
        XCTAssertEqual(validator.validateEventName("my-event"), "myevent")
        XCTAssertEqual(validator.validateEventName("my-event.name"), "myeventname")
    }
    
    func test_event_name_truncates_at_40_chars() {
        let validator = FirebaseValidator()
        let longName = String(repeating: "a", count: 50)
        let result = validator.validateEventName(longName)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 40)
    }
    
    func test_event_name_cleans_up_multiple_underscores() {
        let validator = FirebaseValidator()
        validator.setInvalidCharStrategy(FirebaseValidator.Validation.Strategy.replace)
        XCTAssertEqual(validator.validateEventName("my---event"), "my_event")
    }
    
    func test_event_name_removes_leading_and_trailing_underscores() {
        let validator = FirebaseValidator()
        XCTAssertEqual(validator.validateEventName("_event_"), "event")
    }
    
    // MARK: - User Property Name Tests
    
    func test_valid_user_property_name_passes_validation() {
        let validator = FirebaseValidator()
        XCTAssertEqual(validator.validateUserPropertyName("custom_prop"), "custom_prop")
    }
    
    func test_empty_user_property_name_returns_nil() {
        let validator = FirebaseValidator()
        XCTAssertNil(validator.validateUserPropertyName(""))
        XCTAssertNil(validator.validateUserPropertyName("   "))
    }
    
    func test_reserved_user_property_names_return_nil() {
        let validator = FirebaseValidator()
        XCTAssertNil(validator.validateUserPropertyName("user_id"))
        XCTAssertNil(validator.validateUserPropertyName("first_open_time"))
        XCTAssertNil(validator.validateUserPropertyName("last_deep_link_referrer"))
    }
    
    func test_reserved_prefixes_are_removed_from_user_property_names() {
        let validator = FirebaseValidator()
        XCTAssertEqual(validator.validateUserPropertyName("firebase_prop"), "prop")
        XCTAssertEqual(validator.validateUserPropertyName("google_prop"), "prop")
        XCTAssertEqual(validator.validateUserPropertyName("ga_prop"), "prop")
    }
    
    func test_user_property_name_starting_with_number_gets_prefix() {
        let validator = FirebaseValidator()
        XCTAssertEqual(validator.validateUserPropertyName("123property"), "prop_123property")
    }
    
    func test_user_property_name_with_invalid_chars_uses_replace_strategy() {
        let validator = FirebaseValidator()
        validator.setInvalidCharStrategy(FirebaseValidator.Validation.Strategy.replace)
        XCTAssertEqual(validator.validateUserPropertyName("my-prop.name"), "my_prop_name")
    }
    
    func test_user_property_name_with_invalid_chars_uses_remove_strategy() {
        let validator = FirebaseValidator()
        validator.setInvalidCharStrategy(FirebaseValidator.Validation.Strategy.remove)
        XCTAssertEqual(validator.validateUserPropertyName("my-prop"), "myprop")
    }
    
    func test_user_property_name_truncates_at_24_chars() {
        let validator = FirebaseValidator()
        let longName = String(repeating: "a", count: 30)
        let result = validator.validateUserPropertyName(longName)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 24)
    }
    
    // MARK: - Parameter Name Tests
    
    func test_valid_parameter_name_passes_validation() {
        let validator = FirebaseValidator()
        XCTAssertEqual(validator.validateParameterName("valid_param"), "valid_param")
    }
    
    func test_empty_parameter_name_returns_nil() {
        let validator = FirebaseValidator()
        XCTAssertNil(validator.validateParameterName(""))
        XCTAssertNil(validator.validateParameterName("   "))
    }
    
    func test_reserved_prefixes_are_removed_from_parameter_names() {
        let validator = FirebaseValidator()
        XCTAssertEqual(validator.validateParameterName("firebase_param"), "param")
        XCTAssertEqual(validator.validateParameterName("google_param"), "param")
        XCTAssertEqual(validator.validateParameterName("ga_param"), "param")
    }
    
    func test_parameter_name_that_is_only_reserved_prefix_returns_nil() {
        let validator = FirebaseValidator()
        XCTAssertNil(validator.validateParameterName("firebase_"))
        XCTAssertNil(validator.validateParameterName("google_"))
        XCTAssertNil(validator.validateParameterName("ga_"))
    }
    
    func test_parameter_name_starting_with_number_gets_prefix() {
        let validator = FirebaseValidator()
        XCTAssertEqual(validator.validateParameterName("123param"), "param_123param")
    }
    
    func test_parameter_name_with_invalid_chars_uses_replace_strategy() {
        let validator = FirebaseValidator()
        validator.setInvalidCharStrategy(FirebaseValidator.Validation.Strategy.replace)
        XCTAssertEqual(validator.validateParameterName("my-param.name"), "my_param_name")
    }
    
    func test_parameter_name_with_invalid_chars_uses_remove_strategy() {
        let validator = FirebaseValidator()
        validator.setInvalidCharStrategy(FirebaseValidator.Validation.Strategy.remove)
        XCTAssertEqual(validator.validateParameterName("my-param"), "myparam")
    }
    
    func test_parameter_name_truncates_at_40_chars() {
        let validator = FirebaseValidator()
        let longName = String(repeating: "a", count: 50)
        let result = validator.validateParameterName(longName)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 40)
    }
    
    // MARK: - Parameter Value Tests
    
    func test_parameter_value_within_limit_is_unchanged() {
        let validator = FirebaseValidator()
        let value = "short_value"
        XCTAssertEqual(validator.validateParameterValue(value), value)
    }
    
    func test_parameter_value_truncates_at_100_chars_in_standard_mode() {
        let validator = FirebaseValidator()
        validator.setGA360Mode(false)
        let longValue = String(repeating: "x", count: 150)
        XCTAssertEqual(validator.validateParameterValue(longValue).count, 100)
    }
    
    func test_parameter_value_truncates_at_500_chars_in_ga360_mode() {
        let validator = FirebaseValidator()
        validator.setGA360Mode(true)
        let longValue = String(repeating: "x", count: 600)
        XCTAssertEqual(validator.validateParameterValue(longValue).count, 500)
    }
    
    // MARK: - User Property Value Tests
    
    func test_user_property_value_within_limit_is_unchanged() {
        let validator = FirebaseValidator()
        let value = "short"
        XCTAssertEqual(validator.validateUserPropertyValue(value), value)
    }
    
    func test_user_property_value_truncates_at_36_chars() {
        let validator = FirebaseValidator()
        let longValue = String(repeating: "x", count: 50)
        XCTAssertEqual(validator.validateUserPropertyValue(longValue).count, 36)
    }
}
