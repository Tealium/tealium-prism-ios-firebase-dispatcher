# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - TBD

### Added
- Initial release of TealiumPrismFirebase dispatcher.
- Support for Firebase Analytics commands: `logevent`, `setuserid`, `setuserproperty`, `setuserproperties`, `setdefaultparameters`, `setconsent`, `resetdata`, `setsessiontimeout`, `setanalyticscollectionenabled`, `initiateconversionmeasurement`.
- JSON-based remote configuration via `TealiumSettings.json`.
- Programmatic configuration via `FirebaseSettingsBuilder`.
- Support for iOS 15+, tvOS 15+, macOS 10.15+.
