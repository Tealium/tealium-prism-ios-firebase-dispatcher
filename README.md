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

> **Note:** JSON `log_level` strings map 1:1 to `FirebaseLoggerLevel` cases used in programmatic configuration (e.g. `"min"` → `.min`, `"debug"` → `.debug`).

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
| `setMappings(_ block: (FirebaseMappings) -> Void)` | Configure data mappings |
| `setEnabled(_ enabled: Bool)` | Enable or disable the module |
| `setOrder(_ order: Int)` | Dispatcher execution order |
| `setRules(_ rules: RuleGroup)` | Conditional dispatch rules |

## Commands

| Command | Firebase API |
|---|---|
| `logevent` | `Analytics.logEvent(_:parameters:)` |
| `setuserid` | `Analytics.setUserID(_:)` |
| `setuserproperty` | `Analytics.setUserProperty(_:forName:)` |
| `resetdata` | `Analytics.resetAnalyticsData()` |
| `setdefaultparameters` | `Analytics.setDefaultEventParameters(_:)` |
| `setconsent` | `Analytics.setConsent(_:)` |
| `setsessiontimeout` | `Analytics.setSessionTimeoutInterval(_:)` |
| `setanalyticscollectionenabled` | `Analytics.setAnalyticsCollectionEnabled(_:)` |
| `initiateconversionmeasurement` | `Analytics.initiateOnDeviceConversionMeasurement(...)` |

The Firebase Dispatcher routes dispatch data to Firebase using the Tealium Prism [Mappings](https://github.com/Tealium/tealium-prism-swift) system. Each command below includes the JSON and programmatic mapping configuration.

JSON mapping objects are entries in the `"mappings"` array of your `TealiumSettings.json` module configuration. Programmatic mappings use `FirebaseMappings` with type-safe `FirebaseCommand` and `FirebaseDestination` enums — `mapCommand(_:)` declares which command a mapping group handles, and `mapFrom(_:to:)` maps a source key to a Firebase destination. See the [Tealium Prism SDK documentation](https://github.com/Tealium/tealium-prism-swift) for a full explanation of the Mappings API.

> See the Example app's `TealiumSettings.json` for a complete configuration covering all commands.

In all JSON mapping examples below, replace `YOUR_EVENT_NAME` with the `tealium_event` value you use in your `teal.track(...)` calls to trigger the command (e.g. `"user_logout"` for `resetdata`, `"app_launch"` for `setdefaultparameters`).

Firebase-reserved parameter constants (`AnalyticsParameterValue`, `AnalyticsParameterCurrency`, etc.) are documented in the [Firebase Analytics event parameters reference](https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Constants).

---

### Log Event

Logs an event to Firebase Analytics. Supports predefined Firebase events and custom events, with optional parameters and nested item arrays for e-commerce.

**command_name:** `logevent`

There are two mapping approaches for this command:

#### Approach 1 — Explicit event name

`tealium_event` identifies the command type. The Firebase event name is passed as a separate `event_name` field in the dispatch data. This is consistent with all other commands.

**Dispatch data:**
```swift
teal.track("log_event", data: [
    "event_name": "purchase",
    "total": 99.99,
    "currency": "USD"
])
```

**JSON Mappings:**
```json
{
    "destination": { "key": "command_name" },
    "parameters": {
        "reference": { "key": "tealium_event" },
        "filter": { "value": "log_event" },
        "map_to": { "value": "logevent" }
    }
},
{
    "destination": { "path": "event_name" },
    "parameters": { "reference": { "key": "event_name" } }
},
{
    "destination": { "path": "parameters.value" },
    "parameters": { "reference": { "key": "total" } }
},
{
    "destination": { "path": "parameters.currency" },
    "parameters": { "reference": { "key": "currency" } }
}
```

**Programmatic:**
```swift
builder.setMappings { mappings in
    mappings.mapCommand(.logEvent)
    mappings.mapFrom("event_name", to: .eventName)
    mappings.mapFrom("total", to: .eventParam(AnalyticsParameterValue))
    mappings.mapFrom("currency", to: .eventParam(AnalyticsParameterCurrency))
}
```

#### Approach 2 — Shortcut: `tealium_event` as event name

`tealium_event` is both the trigger and the Firebase event name. No separate `event_name` field is needed. Useful when your Tealium event names already match Firebase event names.

**Dispatch data:**
```swift
teal.track("purchase", data: [
    "total": 99.99,
    "currency": "USD"
])
```

**JSON Mappings:**
```json
{
    "destination": { "key": "command_name" },
    "parameters": {
        "reference": { "key": "tealium_event" },
        "filter": { "value": "purchase" },
        "map_to": { "value": "logevent" }
    }
},
{
    "destination": { "path": "event_name" },
    "parameters": { "reference": { "key": "tealium_event" } }
},
{
    "destination": { "path": "parameters.value" },
    "parameters": { "reference": { "key": "total" } }
},
{
    "destination": { "path": "parameters.currency" },
    "parameters": { "reference": { "key": "currency" } }
}
```

**Programmatic:**
```swift
builder.setMappings { mappings in
    mappings.mapCommand(.logEvent)
    mappings.mapFrom("tealium_event", to: .eventName)
    mappings.mapFrom("total", to: .eventParam(AnalyticsParameterValue))
    mappings.mapFrom("currency", to: .eventParam(AnalyticsParameterCurrency))
}
```

> With Approach 2, each Firebase event name requires its own `command_name` filter mapping. Approach 1 uses a single `"log_event"` filter for all events.

#### Item Formats

Items under `parameters.items` support two equivalent formats:

**Object of arrays** (Tealium convention — each property is an array of values per item):

```json
"items": {
    "item_id":   ["SKU001", "SKU002"],
    "item_name": ["Widget", "Gadget"],
    "price":     [29.99, 70.00]
}
```

**Array of objects** (Firebase-ready format):

```json
"items": [
    { "item_id": "SKU001", "item_name": "Widget", "price": 29.99 },
    { "item_id": "SKU002", "item_name": "Gadget", "price": 70.00 }
]
```

Both formats produce identical Firebase output. When using object of arrays, all arrays must have the same length.

---

### Set User ID

Associates analytics data with a specific user.

**command_name:** `setuserid`

#### JSON Mappings

```json
{
    "destination": { "key": "command_name" },
    "parameters": {
        "reference": { "key": "tealium_event" },
        "filter": { "value": "YOUR_EVENT_NAME" },
        "map_to": { "value": "setuserid" }
    }
},
{
    "destination": { "path": "user_id" },
    "parameters": { "reference": { "key": "user_id" } }
}
```

#### Programmatic

```swift
builder.setMappings { mappings in
    mappings.mapCommand(.setUserId)
    mappings.mapFrom("user_id", to: .userId)
}
```

> Passing an empty string clears the user ID.

---

### Set User Property

Sets one or more user properties. Properties persist across sessions. Firebase supports up to 25 custom user property names.

**command_name:** `setuserproperty`

#### JSON Mappings

```json
{
    "destination": { "key": "command_name" },
    "parameters": {
        "reference": { "key": "tealium_event" },
        "filter": { "value": "YOUR_EVENT_NAME" },
        "map_to": { "value": "setuserproperty" }
    }
},
{
    "destination": { "path": "property_name" },
    "parameters": { "reference": { "key": "property_name" } }
},
{
    "destination": { "path": "property_value" },
    "parameters": { "reference": { "key": "property_value" } }
}
```

To set multiple properties in a single dispatch, map source keys whose values are arrays. Both arrays must have the same length — each index pairs one name with one value:

```json
{
    "property_name": ["subscription_tier", "user_level"],
    "property_value": ["premium", "expert"]
}
```

#### Programmatic

```swift
builder.setMappings { mappings in
    mappings.mapCommand(.setUserProperty)
    mappings.mapFrom("property_name", to: .userPropertyName)
    mappings.mapFrom("property_value", to: .userPropertyValue)
}
```

> Passing an empty string as `property_value` removes that property from Firebase.

---

### Set Default Parameters

Sets parameters that are automatically appended to every subsequent event. Useful for app-wide context such as version or locale.

**command_name:** `setdefaultparameters`

#### JSON Mappings

```json
{
    "destination": { "key": "command_name" },
    "parameters": {
        "reference": { "key": "tealium_event" },
        "filter": { "value": "YOUR_EVENT_NAME" },
        "map_to": { "value": "setdefaultparameters" }
    }
},
{
    "destination": { "path": "parameters.version" },
    "parameters": { "reference": { "key": "app_version" } }
},
{
    "destination": { "path": "parameters.language" },
    "parameters": { "reference": { "key": "app_language" } }
}
```

#### Programmatic

```swift
builder.setMappings { mappings in
    mappings.mapCommand(.setDefaultParameters)
    mappings.mapFrom("app_version", to: .defaultParam("version"))
    mappings.mapFrom("app_language", to: .defaultParam("language"))
}
```

> **Clearing defaults:** To clear all previously set default parameters, dispatch the `setdefaultparameters` command with no `parameters` key in the mapped output (i.e. none of the source keys resolve to a value).
>
> Map a dedicated event to the command, then dispatch it with none of the parameter source keys present:
> ```json
> {
>     "destination": { "key": "command_name" },
>     "parameters": {
>         "reference": { "key": "tealium_event" },
>         "filter": { "value": "clear_defaults" },
>         "map_to": { "value": "setdefaultparameters" }
>     }
> }
> ```
> ```swift
> teal.track("clear_defaults", data: [:])
> ```
> Because `data` carries none of the `parameters.*` source keys (`app_version`, `app_language`), no parameters resolve and Firebase clears all default event parameters.

---

### Set Session Timeout

Overrides the session timeout interval at runtime. Firebase default is 30 minutes.

**command_name:** `setsessiontimeout`

#### JSON Mappings

```json
{
    "destination": { "key": "command_name" },
    "parameters": {
        "reference": { "key": "tealium_event" },
        "filter": { "value": "YOUR_EVENT_NAME" },
        "map_to": { "value": "setsessiontimeout" }
    }
},
{
    "destination": { "path": "session_timeout_seconds" },
    "parameters": { "reference": { "key": "session_timeout_seconds" } }
}
```

#### Programmatic

```swift
builder.setMappings { mappings in
    mappings.mapCommand(.setSessionTimeout)
    mappings.mapFrom("session_timeout_seconds", to: .sessionTimeout)
}
```

---

### Set Analytics Collection Enabled

Enables or disables Firebase Analytics data collection at runtime. When disabled, collection stops but previously collected data is retained.

**command_name:** `setanalyticscollectionenabled`

#### JSON Mappings

```json
{
    "destination": { "key": "command_name" },
    "parameters": {
        "reference": { "key": "tealium_event" },
        "filter": { "value": "YOUR_EVENT_NAME" },
        "map_to": { "value": "setanalyticscollectionenabled" }
    }
},
{
    "destination": { "path": "analytics_collection_enabled" },
    "parameters": { "reference": { "key": "analytics_enabled" } }
}
```

#### Programmatic

```swift
builder.setMappings { mappings in
    mappings.mapCommand(.setAnalyticsCollectionEnabled)
    mappings.mapFrom("analytics_enabled", to: .analyticsEnabled)
}
```

---

### Set Consent

Configures end-user consent state for device identifiers. Should be called before logging any events.

**command_name:** `setconsent`

#### JSON Mappings

```json
{
    "destination": { "key": "command_name" },
    "parameters": {
        "reference": { "key": "tealium_event" },
        "filter": { "value": "YOUR_EVENT_NAME" },
        "map_to": { "value": "setconsent" }
    }
},
{
    "destination": { "path": "consent_settings.ad_storage" },
    "parameters": { "reference": { "key": "ad_storage_consent" } }
},
{
    "destination": { "path": "consent_settings.analytics_storage" },
    "parameters": { "reference": { "key": "analytics_storage_consent" } }
}
```

#### Programmatic

```swift
builder.setMappings { mappings in
    mappings.mapCommand(.setConsent)
    mappings.mapFrom("ad_storage_consent", to: .consentSetting(.adStorage))
    mappings.mapFrom("analytics_storage_consent", to: .consentSetting(.analyticsStorage))
}
```

#### Consent Types

| Consent Type | `FirebaseDestination` | Status Values |
|---|---|---|
| `ad_storage` | `.consentSetting(.adStorage)` | `granted`, `denied` |
| `analytics_storage` | `.consentSetting(.analyticsStorage)` | `granted`, `denied` |
| `ad_user_data` | `.consentSetting(.adUserData)` | `granted`, `denied` |
| `ad_personalization` | `.consentSetting(.adPersonalization)` | `granted`, `denied` |

> Unknown consent types or statuses are rejected and the command fails. Valid types: `ad_storage`, `analytics_storage`, `ad_user_data`, `ad_personalization`. Valid statuses: `granted`, `denied`.

---

### Reset Data

Clears all analytics data for this app instance from the device and resets the app instance ID. Use on user logout or when privacy regulations require data deletion.

**command_name:** `resetdata`

#### JSON Mappings

```json
{
    "destination": { "key": "command_name" },
    "parameters": {
        "reference": { "key": "tealium_event" },
        "filter": { "value": "YOUR_EVENT_NAME" },
        "map_to": { "value": "resetdata" }
    }
}
```

#### Programmatic

```swift
builder.setMappings { mappings in
    mappings.mapCommand(.resetData)
}
```

---

### Initiate Conversion Measurement

Initiates on-device conversion measurement for Google Ads attribution. You may supply multiple credentials in a single dispatch — only one is forwarded to Firebase per call, selected by the priority list below.

**command_name:** `initiateconversionmeasurement`

#### JSON Mappings

```json
{
    "destination": { "key": "command_name" },
    "parameters": {
        "reference": { "key": "tealium_event" },
        "filter": { "value": "YOUR_EVENT_NAME" },
        "map_to": { "value": "initiateconversionmeasurement" }
    }
},
{
    "destination": { "path": "hashed_email_address" },
    "parameters": { "reference": { "key": "hashed_email" } }
}
```

#### Programmatic

```swift
builder.setMappings { mappings in
    mappings.mapCommand(.initiateConversionMeasurement)
    mappings.mapFrom("hashed_email", to: .conversionHashedEmail)
}
```

#### Credential Priority

When multiple credentials are mapped, the dispatcher picks exactly one according to this priority (first match wins):

1. `hashed_email_address` → `.conversionHashedEmail`
2. `hashed_phone_number` → `.conversionHashedPhone`
3. `email_address` → `.conversionEmail`
4. `phone_number` → `.conversionPhone`

> `hashed_email_address` and `hashed_phone_number` must be **Base64-encoded SHA-256 hashes**. Passing a plain string will be rejected.

## License

TealiumPrismFirebase is available under a commercial license. See the [LICENSE](./LICENSE) file for more info.
