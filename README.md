# Tealium Prism Firebase Dispatcher for iOS

[![Version](https://img.shields.io/cocoapods/v/TealiumPrismFirebase.svg?style=flat)](https://cocoapods.org/pods/TealiumPrismFirebase)
[![License](https://img.shields.io/cocoapods/l/TealiumPrismFirebase.svg?style=flat)](https://github.com/Tealium/tealium-prism-ios-firebase-dispatcher/blob/main/LICENSE)
[![Platform](https://img.shields.io/cocoapods/p/TealiumPrismFirebase.svg?style=flat)](https://cocoapods.org/pods/TealiumPrismFirebase)

Command Dispatcher that routes Tealium Prism tracking events to the Firebase Analytics iOS SDK — events, user properties, consent settings, and more.

> **Important:** Firebase Analytics only supports a single shared instance. Only one `firebaseDispatcher` can be active at a time in your app.

## Requirements

| Dependency              | Version |
|-------------------------|---------|
| iOS                     | 15.0+   |
| macOS                   | 10.15+  |
| tvOS                    | 15.0+   |
| Swift                   | 5.5+    |
| Tealium Prism Core      | >= 0.5.0 |
| Firebase iOS SDK        | 12.0.0+ |

## Installation

### Swift Package Manager

1. In Xcode, select **File > Add Package Dependencies**.
2. Enter the repository URL: `https://github.com/Tealium/tealium-prism-ios-firebase-dispatcher`
3. Configure the version rules. **Up to Next Major** is recommended.
4. Select `TealiumPrismFirebase` and add it to your app target.

Or add it manually to `Package.swift`:

```swift
.package(url: "https://github.com/Tealium/tealium-prism-ios-firebase-dispatcher.git", from: "1.0.0")
```

### CocoaPods

Add the following line to your `Podfile`:

```ruby
pod 'TealiumPrismFirebase'
```

### Firebase Setup

Place `GoogleService-Info.plist` in the app target root. The Firebase Dispatcher calls `FirebaseApp.configure()` automatically on first use. If you need custom initialization order (e.g. for Crashlytics), call `FirebaseApp.configure()` manually — add `import FirebaseCore` to your app entry point and call it before `Tealium.create(config:)`. The dispatcher will detect the existing `FirebaseApp` and skip its own initialization.

## Example App

To run the example project, clone the repo and open `Example/Example.xcodeproj` in Xcode. Add a real `GoogleService-Info.plist` and run the Example scheme.

The example app demonstrates:
- Automatic and manual Firebase initialization approaches
- Every Firebase command with real-world use cases
- Purchase events with items and custom parameters
- User ID and user property management
- Consent settings (grant/deny all)
- On-device conversion measurement with plaintext and hashed credentials

## Quick Start

Register the Firebase Dispatcher when initializing Tealium Prism:

```swift
import TealiumPrismCore
import TealiumPrismFirebase

let config = TealiumConfig(
    account: "my_account",
    profile: "my_profile",
    environment: "prod",
    modules: [
        Modules.collect(),
        Modules.firebaseDispatcher(),
    ],
    settingsFile: "TealiumSettings"
)
let tealium = Tealium.create(config: config)
```

## Configuration

The Firebase Dispatcher can be configured via a local JSON settings file, remote settings, or programmatically.

### Configuration Options

| Setting | JSON Key | Type |
|---|---|---|
| Session timeout | `session_timeout_seconds` | `Double` (seconds) |
| Analytics collection enabled | `analytics_collection_enabled` | `Bool` |
| Log level | `log_level` | `String` — `"min"`, `"error"`, `"warning"`, `"notice"`, `"info"`, `"debug"`, `"max"` |

If a setting is omitted, Firebase uses its own default value.

> **Note:** JSON `log_level` strings map 1:1 onto `FirebaseLoggerLevel` cases (e.g. `"min"` → `.min`, `"debug"` → `.debug`). The reverse is not one-to-one: Firebase defines `.min` and `.error` with the same underlying value, as it does `.max` and `.debug`, so `setLogLevel(.min)` persists as `"error"` and `setLogLevel(.max)` as `"debug"`. The effect on Firebase is identical.

### JSON Settings

Configure the module in your `TealiumSettings.json` file:

```json
{
    "modules": {
        "FirebaseDispatcher": {
            "module_type": "FirebaseDispatcher",
            "configuration": {
                "session_timeout_seconds": 1800,
                "analytics_collection_enabled": true,
                "log_level": "debug"
            }
        }
    }
}
```

### Programmatic Configuration

Use `FirebaseSettingsBuilder` to enforce settings that cannot be overridden remotely:

```swift
Modules.firebaseDispatcher(forcingSettings: { builder in
    builder
        .setSessionTimeout(30.minutes)
        .setAnalyticsEnabled(true)
        .setLogLevel(.min)
})
```

> **Note:** Programmatic settings always take precedence over local and remote settings. Only use them for values that must never be changed remotely.

## Settings Builder Reference

`FirebaseSettingsBuilder` extends `DispatcherSettingsBuilder<FirebaseMappings>` and provides these methods:

| Method | Description |
|---|---|
| `setSessionTimeout(_ sessionTimeout: TimeFrame)` | Session timeout (e.g. `30.minutes`) |
| `setAnalyticsEnabled(_ enabled: Bool)` | Enable or disable analytics collection |
| `setLogLevel(_ level: FirebaseLoggerLevel)` | Firebase internal log verbosity |
| `setMappings(_ mappingsSetup: @escaping (FirebaseMappings) -> Void)` | Configure data mappings |
| `setEnabled(_ enabled: Bool)` | Enable or disable the module |
| `setOrder(_ order: Int)` | Dispatcher execution order |
| `setRules(_ rules: Rule<String>)` | Conditional dispatch rules by load rule ID |

## Commands

| Command | Firebase API | Guide |
|---|---|---|
| `logevent` | `Analytics.logEvent(_:parameters:)` | [LogEvent](docs/guides/LogEvent.md) |
| `setuserid` | `Analytics.setUserID(_:)` | [SetUserID](docs/guides/SetUserID.md) |
| `setuserproperty` | `Analytics.setUserProperty(_:forName:)` | [SetUserProperty](docs/guides/SetUserProperty.md) |
| `resetdata` | `Analytics.resetAnalyticsData()` | [ResetData](docs/guides/ResetData.md) |
| `setdefaultparameters` | `Analytics.setDefaultEventParameters(_:)` | [SetDefaultParameters](docs/guides/SetDefaultParameters.md) |
| `setconsent` | `Analytics.setConsent(_:)` | [SetConsent](docs/guides/SetConsent.md) |
| `setsessiontimeout` | `Analytics.setSessionTimeoutInterval(_:)` | [SetSessionTimeout](docs/guides/SetSessionTimeout.md) |
| `setanalyticscollectionenabled` | `Analytics.setAnalyticsCollectionEnabled(_:)` | [SetAnalyticsCollectionEnabled](docs/guides/SetAnalyticsCollectionEnabled.md) |
| `initiateconversionmeasurement` | `Analytics.initiateOnDeviceConversionMeasurement(...)` | [InitiateConversionMeasurement](docs/guides/InitiateConversionMeasurement.md) |

The Firebase Dispatcher routes dispatch data to Firebase using the Tealium Prism Mappings system, and each
command has its own guide covering the JSON and programmatic mapping configuration, payload shapes, and
error behaviour. Start with [Mappings](docs/guides/Mappings.md) for the concepts shared by all commands —
`command_name` binding, destinations, and the JSON mapping schema.

The same guides are published alongside the generated API reference at
[tealium.github.io/tealium-prism-ios-firebase-dispatcher](https://tealium.github.io/tealium-prism-ios-firebase-dispatcher/).

> See the Example app's `TealiumSettings.json` for a complete configuration covering all commands.

## API Reference

Generated documentation for the public API is published at
[tealium.github.io/tealium-prism-ios-firebase-dispatcher](https://tealium.github.io/tealium-prism-ios-firebase-dispatcher/).

Build it locally with:

```bash
bundle install
./scripts/docs.sh
```

Output lands in `_site`.

## License

TealiumPrismFirebase is available under a commercial license. See the [LICENSE](./LICENSE) file for more info.
