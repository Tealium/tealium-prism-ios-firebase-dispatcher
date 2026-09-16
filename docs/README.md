# Tealium Prism Firebase Dispatcher for iOS

Command Dispatcher that routes Tealium Prism tracking events to the Firebase Analytics iOS SDK — events,
user properties, consent settings, and more.

> **Important:** Firebase Analytics only supports a single shared instance. Only one `firebaseDispatcher`
> can be active at a time in your app.

## Requirements

| Dependency              | Version  |
|-------------------------|----------|
| iOS                     | 15.0+    |
| macOS                   | 10.15+   |
| tvOS                    | 15.0+    |
| Swift                   | 6.0+     |
| Tealium Prism Core      | >= 0.5.0 |
| Firebase iOS SDK        | 12.0.0+  |

## Installation

### Swift Package Manager

1. In Xcode, select **File > Add Package Dependencies**.
2. Enter the repository URL: `https://github.com/Tealium/tealium-prism-ios-firebase-dispatcher`
3. Configure the version rules. **Up to Next Major** is recommended.
4. Select `TealiumPrismFirebase` and add it to your app target.

Or add it manually to `Package.swift`:

```swift
.package(url: "https://github.com/Tealium/tealium-prism-ios-firebase-dispatcher.git", from: "0.1.0")
```

### CocoaPods

Add the following line to your `Podfile`:

```ruby
pod 'TealiumPrismFirebase'
```

### Firebase Setup

Place `GoogleService-Info.plist` in the app target root. The Firebase Dispatcher calls
`FirebaseApp.configure()` automatically on first use. If you need custom initialization order (e.g. for
Crashlytics), call `FirebaseApp.configure()` manually — add `import FirebaseCore` to your app entry point
and call it before `Tealium.create(config:)`. The dispatcher will detect the existing `FirebaseApp` and
skip its own initialization.

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

The Firebase Dispatcher can be configured via a local JSON settings file, remote settings, or
programmatically. See [FirebaseSettingsBuilder](Classes/FirebaseSettingsBuilder.html) for the full
configuration reference — settings keys, defaults, and the programmatic builder methods.

## Commands

| Command | Firebase API | Guide |
|---|---|---|
| `logevent` | `Analytics.logEvent(_:parameters:)` | [LogEvent](logevent.html) |
| `setuserid` | `Analytics.setUserID(_:)` | [SetUserID](setuserid.html) |
| `setuserproperty` | `Analytics.setUserProperty(_:forName:)` | [SetUserProperty](setuserproperty.html) |
| `resetdata` | `Analytics.resetAnalyticsData()` | [ResetData](resetdata.html) |
| `setdefaultparameters` | `Analytics.setDefaultEventParameters(_:)` | [SetDefaultParameters](setdefaultparameters.html) |
| `setconsent` | `Analytics.setConsent(_:)` | [SetConsent](setconsent.html) |
| `setsessiontimeout` | `Analytics.setSessionTimeoutInterval(_:)` | [SetSessionTimeout](setsessiontimeout.html) |
| `setanalyticscollectionenabled` | `Analytics.setAnalyticsCollectionEnabled(_:)` | [SetAnalyticsCollectionEnabled](setanalyticscollectionenabled.html) |
| `initiateconversionmeasurement` | `Analytics.initiateOnDeviceConversionMeasurement(...)` | [InitiateConversionMeasurement](initiateconversionmeasurement.html) |

The Firebase Dispatcher routes dispatch data to Firebase using the Tealium Prism Mappings system, and each
command has its own guide covering the JSON and programmatic mapping configuration, payload shapes, and
error behaviour. Start with [Mappings](mappings.html) for the concepts shared by all commands —
`command_name` binding, destinations, and the JSON mapping schema.

## Example App

The [example app](https://github.com/Tealium/tealium-prism-ios-firebase-dispatcher/tree/main/Example)
demonstrates every command with real-world use cases, both Firebase initialization approaches, and a
complete `TealiumSettings.json` covering all commands.

## License

TealiumPrismFirebase is available under a commercial license. See the
[LICENSE](https://github.com/Tealium/tealium-prism-ios-firebase-dispatcher/blob/main/LICENSE) file for
more info.
