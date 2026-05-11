# Tealium Prism Firebase Dispatcher for iOS

Command Dispatcher that routes Tealium tracking events to the Firebase Analytics iOS SDK.

Full schema, command list, and cross-platform semantics are documented on Confluence:
[Firebase Dispatcher](https://tealium.atlassian.net/wiki/spaces/MOB/pages/5903974885/Firebase+Dispatcher).

## Requirements

| Dependency              | Version |
|-------------------------|---------|
| iOS                     | 15.0+   |
| macOS                   | 10.15+  |
| tvOS                    | 15.0+   |
| watchOS                 | 7.0+    |
| Swift                   | 5.5+    |
| Tealium Prism Core      | dev     |
| Firebase iOS SDK        | 12.0.0+ |

## Installation

### Swift Package Manager

Add the package dependency in Xcode or your `Package.swift`:

```swift
.package(url: "https://github.com/Tealium/tealium-prism-ios-firebase-dispatcher.git", from: "1.0.0")
```

Then add `TealiumPrismFirebase` to your target dependencies:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "TealiumPrismFirebase", package: "tealium-prism-ios-firebase-dispatcher")
    ]
)
```

### CocoaPods

```ruby
pod 'TealiumPrismFirebase', '~> 1.0'
```

Place `GoogleService-Info.plist` in the app target root.

Firebase is initialized automatically by the `FirebaseAnalytics` framework; no explicit
`FirebaseApp.configure()` is required unless another Firebase product needs custom ordering.

## Quick Start

```swift
import TealiumPrismCore
import TealiumPrismFirebase
import FirebaseAnalytics

class TealiumHelper {
    private(set) var teal: Tealium?

    func startTealium() {
        let config = TealiumConfig(
            account: "myaccount",
            profile: "myprofile",
            environment: "dev",
            modules: [
                Modules.firebaseDispatcher(forcingSettings: { builder in
                    builder
                        .setSessionTimeout(30.minutes)
                        .setAnalyticsEnabled(true)
                        .setLogLevel(.debug)
                        .setMappings { mappings in
                            mappings.mapCommand(.logEvent)
                            mappings.mapFrom("tealium_event", to: .eventName)
                            mappings.mapFrom("total", to: .eventParam(AnalyticsParameterValue))
                            mappings.mapFrom("currency", to: .eventParam(AnalyticsParameterCurrency))
                            mappings.mapFrom("product_ids", to: .itemParam(AnalyticsParameterItemID))
                            mappings.mapFrom("product_names", to: .itemParam(AnalyticsParameterItemName))

                            mappings.mapCommand(.setUserId)
                            mappings.mapFrom("customer_id", to: .userId)

                            mappings.mapCommand(.setUserProperty)
                            mappings.mapFrom("prop_name", to: .userPropertyName)
                            mappings.mapFrom("prop_value", to: .userPropertyValue)

                            mappings.mapCommand(.setConsent)
                        }
                })
            ]
        )

        self.teal = Tealium.create(config: config)
    }
}
```

## Supported Commands

| Command                          | Firebase API                                    |
|----------------------------------|-------------------------------------------------|
| `logevent`                       | `Analytics.logEvent(_:parameters:)`             |
| `setuserid`                      | `Analytics.setUserID(_:)`                       |
| `setuserproperty`                | `Analytics.setUserProperty(_:forName:)`         |
| `resetdata`                      | `Analytics.resetAnalyticsData()`                |
| `setdefaultparameters`           | `Analytics.setDefaultEventParameters(_:)`       |
| `setconsent`                     | `Analytics.setConsent(_:)`                      |
| `setsessiontimeout`              | `Analytics.setSessionTimeoutInterval(_:)`       |
| `setanalyticscollectionenabled`  | `Analytics.setAnalyticsCollectionEnabled(_:)`   |
| `initiateconversionmeasurement`  | `Analytics.initiateOnDeviceConversionMeasurement(emailAddress:/phoneNumber:)` |

`initiateconversionmeasurement` is iOS only — the Firebase Android SDK does not expose the
on-device conversion measurement API.

See the Confluence page for the full payload schema, reserved event names, consent type/status
mappings, and the `items` array-of-objects / parallel-arrays formats.

## Configuration

| Key                              | Type      | Default          | Notes                              |
|----------------------------------|-----------|------------------|------------------------------------|
| `session_timeout_seconds`        | Number    | 1800             | Seconds. Converted to TimeInterval internally. |
| `analytics_collection_enabled`   | Bool      | `true`           |                                    |
| `log_level`                      | String    | Firebase default | min, error, warning, notice, info, debug, max |

## Example App

The `Example` directory contains a SwiftUI demo that exercises every command. Add a real
`GoogleService-Info.plist` and run the Example scheme. Firebase DebugView will show forwarded events:

```bash
# Enable Firebase debug logging in Xcode scheme:
# Arguments Passed On Launch: -FIRAnalyticsDebugEnabled
```

## Testing

```bash
swift test
```

Or in Xcode: `Cmd+U` on the `TealiumPrismFirebaseTests` scheme.

Unit tests use XCTest with mocked Firebase interface — no device or simulator required.

## License

See [LICENSE](LICENSE).
