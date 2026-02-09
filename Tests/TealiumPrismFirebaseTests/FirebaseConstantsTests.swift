//
//  FirebaseConstantsTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 14/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
import XCTest

final class FirebaseConstantsTests: XCTestCase {
    
    // MARK: - Module Metadata
    
    func test_command_name() {
        XCTAssertEqual(FirebaseConstants.commandName, "command_name")
    }
    
    // MARK: - SetSessionTimeout Command
    
    func test_setsessiontimeout_name() {
        XCTAssertEqual(FirebaseConstants.SetSessionTimeout.name, "setsessiontimeout")
    }
    
    func test_setsessiontimeout_session_timeout() {
        XCTAssertEqual(FirebaseConstants.SetSessionTimeout.Param.sessionTimeout, "session_timeout_seconds")
    }
    
    // MARK: - SetAnalyticsCollectionEnabled Command
    
    func test_setanalyticscollectionenabled_name() {
        XCTAssertEqual(FirebaseConstants.SetAnalyticsCollectionEnabled.name, "setanalyticscollectionenabled")
    }
    
    func test_setanalyticscollectionenabled_analytics_enabled() {
        XCTAssertEqual(FirebaseConstants.SetAnalyticsCollectionEnabled.Param.analyticsEnabled, "analytics_collection_enabled")
    }
    
    // MARK: - LogEvent Command
    
    func test_logevent_name() {
        XCTAssertEqual(FirebaseConstants.LogEvent.name, "logevent")
    }
    
    func test_logevent_event_name() {
        XCTAssertEqual(FirebaseConstants.LogEvent.Param.eventName, "firebase_event_name")
    }
    
    func test_logevent_event_params() {
        XCTAssertEqual(FirebaseConstants.LogEvent.Param.eventParams, "firebase_event_params")
    }
    
    func test_logevent_items() {
        XCTAssertEqual(FirebaseConstants.LogEvent.Param.items, "param_items")
    }
    
    // MARK: - SetUserId Command
    
    func test_setuserid_name() {
        XCTAssertEqual(FirebaseConstants.SetUserId.name, "setuserid")
    }
    
    func test_setuserid_user_id() {
        XCTAssertEqual(FirebaseConstants.SetUserId.Param.userId, "firebase_user_id")
    }
    
    // MARK: - SetUserProperty Command
    
    func test_setuserproperty_name() {
        XCTAssertEqual(FirebaseConstants.SetUserProperty.name, "setuserproperty")
    }
    
    func test_setuserproperty_property_name() {
        XCTAssertEqual(FirebaseConstants.SetUserProperty.Param.propertyName, "firebase_property_name")
    }
    
    func test_setuserproperty_property_value() {
        XCTAssertEqual(FirebaseConstants.SetUserProperty.Param.propertyValue, "firebase_property_value")
    }
    
    // MARK: - ResetData Command
    
    func test_resetdata_name() {
        XCTAssertEqual(FirebaseConstants.ResetData.name, "resetdata")
    }
    
    // MARK: - SetDefaultParameters Command
    
    func test_setdefaultparameters_name() {
        XCTAssertEqual(FirebaseConstants.SetDefaultParameters.name, "setdefaultparameters")
    }
    
    func test_setdefaultparameters_params() {
        XCTAssertEqual(FirebaseConstants.SetDefaultParameters.Param.params, "firebase_params")
    }
    
    // MARK: - SetConsent Command
    
    func test_setconsent_name() {
        XCTAssertEqual(FirebaseConstants.SetConsent.name, "setconsent")
    }
    
    func test_setconsent_ad_storage() {
        XCTAssertEqual(FirebaseConstants.SetConsent.Param.adStorage, "ad_storage")
    }
    
    func test_setconsent_analytics_storage() {
        XCTAssertEqual(FirebaseConstants.SetConsent.Param.analyticsStorage, "analytics_storage")
    }
    
    func test_setconsent_ad_user_data() {
        XCTAssertEqual(FirebaseConstants.SetConsent.Param.adUserData, "ad_user_data")
    }
    
    func test_setconsent_ad_personalization() {
        XCTAssertEqual(FirebaseConstants.SetConsent.Param.adPersonalization, "ad_personalization")
    }
    
    // MARK: - InitiateConversionMeasurement Command
    
    func test_initiateconversionmeasurement_name() {
        XCTAssertEqual(FirebaseConstants.InitiateConversionMeasurement.name, "initiateconversionmeasurement")
    }
    
    func test_initiateconversionmeasurement_email_address() {
        XCTAssertEqual(FirebaseConstants.InitiateConversionMeasurement.Param.emailAddress, "param_email_address")
    }
    
    func test_initiateconversionmeasurement_phone_number() {
        XCTAssertEqual(FirebaseConstants.InitiateConversionMeasurement.Param.phoneNumber, "param_phone_number")
    }
    
    func test_initiateconversionmeasurement_hashed_email_address() {
        XCTAssertEqual(FirebaseConstants.InitiateConversionMeasurement.Param.hashedEmailAddress, "param_hashed_email_address")
    }
    
    func test_initiateconversionmeasurement_hashed_phone_number() {
        XCTAssertEqual(FirebaseConstants.InitiateConversionMeasurement.Param.hashedPhoneNumber, "param_hashed_phone_number")
    }
}
