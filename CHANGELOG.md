# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of Tealium Prism Firebase Dispatcher for iOS.
- Support for 9 Firebase Analytics commands:
  - `logevent` — log events with parameters and items (e-commerce).
  - `setuserid` — set or clear the Firebase user ID.
  - `setuserproperty` — set user properties (single or batch).
  - `resetdata` — reset all Firebase Analytics data.
  - `setdefaultparameters` — set default event parameters.
  - `setconsent` — configure consent settings (ad_storage, analytics_storage, ad_user_data, ad_personalization).
  - `setsessiontimeout` — update session timeout duration.
  - `setanalyticscollectionenabled` — enable or disable analytics collection.
  - `initiateconversionmeasurement` — on-device conversion measurement with email or phone (iOS exclusive).
- Type-safe mappings DSL with `FirebaseCommand`, `FirebaseDestination`, and `FirebaseMappings`.
- Builder-based configuration via `FirebaseSettingsBuilder`.
- Support for items in parallel-arrays and array-of-objects formats.
- Support for hashed email/phone in conversion measurement.
- XCTest-based unit tests with mocked Firebase interface.
- SwiftUI example app demonstrating all commands.
- SPM and CocoaPods support.
- Multi-platform: iOS 15+, macOS 10.15+, tvOS 15+, watchOS 7+.

[Unreleased]: https://github.com/Tealium/tealium-prism-ios-firebase-dispatcher/commits/dev
