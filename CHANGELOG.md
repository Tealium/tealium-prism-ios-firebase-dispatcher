# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0]

### Changed
- **Breaking:** requires Tealium Prism 0.8.0 or later, below 1.0.0.
- **Breaking:** `FirebaseCommand` and `FirebaseDestination` are now `@nonexhaustive` ([SE-0487](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0487-extensible-enums.md)): a `switch` over them needs an `@unknown default` case.
- Command payloads are read with the Prism 0.8.0 extraction helpers. A parameter that can't be read now fails the command with `CommandError.invalidPayload`, wrapping the matching `ExtractionError` (`missing`, `typeMismatch`, `invalidValue` or `empty`). An explicit `null` for a required parameter is reported as `missing` instead of an invalid type. Name and value arrays of different lengths are still reported as `CommandError.arrayLengthMismatch`, and an `initiateconversionmeasurement` payload without any credential as `CommandError.noValidParameters`. The error messages, shown only in the `CommandDispatcher` log, changed accordingly and never include the parameter's value.
- `logevent` fails when `event_name` is blank. Firebase Analytics requires event names of 1 to 40 characters that start with a letter.
- `setconsent` trims the consent status before matching it, and reports a blank or `null` status as such. An empty `consent_settings` object is now reported as `empty` instead of `noValidParameters`.
- `setuserproperty` reports a `property_name` that is an object as `typeMismatch` instead of `empty`, and checks that the name and value arrays have the same length before checking that a name is usable.
- `initiateconversionmeasurement` reads credentials like the other commands. An object or an array now fails with `typeMismatch`; before, it was skipped and the next credential by priority was forwarded instead. Numbers and booleans are converted to strings. Whitespace around every credential is removed, and a credential that is only whitespace fails with `empty` instead of being forwarded to Firebase.
- `initiateconversionmeasurement` checks that `hashed_email_address` and `hashed_phone_number` are a 32-byte SHA-256 digest, as Firebase requires, and also accepts the digest as 64 hexadecimal characters, the format most tools print. Before, any valid Base64 was forwarded, so a hex digest or a plain phone number reached Firebase with the wrong length and Firebase ignored it. A value that isn't a SHA-256 digest now fails with `invalidValue` instead of `invalidParameterType`.
- Requires Firebase iOS SDK 13, Xcode 26.2+ and macOS 11+.

### Removed
- CocoaPods distribution. CocoaPods trunk becomes read-only on 2 December 2026 and Firebase 13 is distributed through Swift Package Manager only.

## [0.2.0]

### Added
- `FirebaseDispatcher` now auto-registers as a default module at app startup. It is enabled by a
  `ModuleSettings` entry for `Modules.Types.firebaseDispatcher` in `SDKSettings`, without needing
  `config.addModule(...)`.

### Changed
- Requires Tealium Prism 0.7.0 or later, below 1.0.0.

## [0.1.0]

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
- Multi-platform: iOS 15+, macOS 10.15+, tvOS 15+.

[0.3.0]: https://github.com/Tealium/tealium-prism-ios-firebase-dispatcher/releases/tag/0.3.0
[0.2.0]: https://github.com/Tealium/tealium-prism-ios-firebase-dispatcher/releases/tag/0.2.0
[0.1.0]: https://github.com/Tealium/tealium-prism-ios-firebase-dispatcher/releases/tag/0.1.0
