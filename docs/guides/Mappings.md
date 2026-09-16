# Mappings

The Firebase Dispatcher never talks to Firebase Analytics directly from your track calls. Instead, every
dispatch is translated into a **command payload** by the Tealium Prism Mappings system, and the
dispatcher then executes the command named in that payload.

A mapping configuration therefore has two jobs:

1. Decide **which command** a dispatch triggers, by writing a value into `command_name`.
2. Decide **which payload fields** the command receives, by mapping source keys from the dispatch data
   onto Firebase destinations.

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

## JSON mappings

JSON mapping objects are entries in the `"mappings"` array of the module configuration in your
`TealiumSettings.json` (or the equivalent remote settings payload). Each entry has a `destination` and a
`parameters` block:

```json
{
    "destination": { "key": "command_name" },
    "parameters": {
        "reference": { "key": "tealium_event" },
        "filter": { "value": "purchase" },
        "map_to": { "value": "logevent" }
    }
}
```

- `destination.key` writes to a top-level payload key; `destination.path` writes to a dotted path such as
  `parameters.currency`.
- `parameters.reference.key` names the source key in the dispatch data.
- `parameters.filter.value` restricts the mapping to dispatches where the source value matches — this is
  how a command is bound to a specific `tealium_event`.
- `parameters.map_to.value` writes a constant instead of the source value, which is what turns a matching
  event into a command name.

## Programmatic mappings

Programmatic mappings use `FirebaseMappings` with the type-safe `FirebaseCommand` and
`FirebaseDestination` enums. `mapCommand(_:)` declares which command a mapping group handles, and
`mapFrom(_:to:)` maps a source key onto a Firebase destination:

```swift
Modules.firebaseDispatcher(forcingSettings: { builder in
    builder.setMappings { mappings in
        mappings.mapCommand(.logEvent).ifValueIn("tealium_event", equals: "purchase")
        mappings.mapFrom("tealium_event", to: .eventName)
        mappings.mapFrom("total", to: .eventParam(AnalyticsParameterValue))
    }
})
```

`mapCommand(_:)` returns `Mappings.CommandOptions`, so the command can be bound in three ways:

| Binding | Meaning |
|---|---|
| `.ifValueIn(_ key:, equals:)` | Apply the command when the given dispatch key equals the given value |
| `.forAllEvents()` | Apply the command to every tracked event |
| `.forAllViews()` | Apply the command to every tracked view |

An unbound `mapCommand(_:)` applies unconditionally to every dispatch the dispatcher receives.

## Destinations

`FirebaseDestination` is the type-safe equivalent of the JSON `destination.path` values:

| Destination | Payload path |
|---|---|
| `.eventName` | `event_name` |
| `.eventParams` | `parameters` |
| `.eventParam(String)` | `parameters.<name>` |
| `.itemParam(String)` | `parameters.items.<name>` |
| `.userId` | `user_id` |
| `.userPropertyName` | `property_name` |
| `.userPropertyValue` | `property_value` |
| `.defaultParams` | `parameters` |
| `.defaultParam(String)` | `parameters.<name>` |
| `.consentSettings` | `consent_settings` |
| `.consentSetting(ConsentType)` | `consent_settings.<type>` |
| `.sessionTimeout` | `session_timeout_seconds` |
| `.analyticsEnabled` | `analytics_collection_enabled` |
| `.conversionEmail` | `email_address` |
| `.conversionPhone` | `phone_number` |
| `.conversionHashedEmail` | `hashed_email_address` |
| `.conversionHashedPhone` | `hashed_phone_number` |

Firebase-reserved parameter constants (`AnalyticsParameterValue`, `AnalyticsParameterCurrency`, …) are
documented in the
[Firebase Analytics event parameters reference](https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Constants).

## Conventions used in these guides

In the per-command guides, replace `YOUR_EVENT_NAME` with the `tealium_event` value you use in your
`teal.track(...)` calls to trigger that command (e.g. `"user_logout"` for `resetdata`).

See the Example app's `TealiumSettings.json` for a complete configuration covering all commands.
