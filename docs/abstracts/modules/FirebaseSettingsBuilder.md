The Firebase module is a `Dispatcher` module that routes Tealium Prism tracking events to the Firebase Analytics iOS SDK — events, user properties, consent settings, and more. Firebase Analytics only supports a single shared instance, so only one Firebase dispatcher can be active at a time in your app.

## Installation/Configuration

The Firebase module can be configured using three different approaches:

### Local and Remote Settings
Configure the module using local JSON settings file (via `settingsFile` parameter) and/or remote settings (via `settingsUrl` parameter):

```swift
var config = TealiumConfig(account: "my_account",
                          profile: "my_profile",
                          environment: "dev",
                          settingsFile: "TealiumSettings",
                          settingsUrl: "https://tags.tiqcdn.com/dle/my_account/my_profile/example_settings.json")
```

The Firebase Dispatcher auto-registers as a default module at app startup, so the settings entry alone is enough to enable it — no need to add it to `modules`. `Modules.firebaseDispatcher(forcingSettings:)` remains the way to force settings from code.

**Default initialization** - module will be initialized only if configured in settings file specified:
```json
{
    "modules": {
        "FirebaseDispatcher": {
            "module_type": "FirebaseDispatcher"
        }
    }
}
```

**Custom configuration** - module with specific settings:
```json
{
    "modules": {
        "FirebaseDispatcher": {
            "module_type": "FirebaseDispatcher",
            "enabled": true,
            "order": 1,
            "configuration": {
                "session_timeout_seconds": 1800,
                "analytics_collection_enabled": true,
                "log_level": "debug"
            }
        }
    }
}
```

If a setting is omitted, Firebase uses its own default value. When both local and remote settings are provided, they are deep merged with remote settings taking priority.

### Programmatic Configuration
Configure the module programmatically by adding it to the `modules` parameter in `TealiumConfig`.

**Default initialization** - module will be initialized with default settings:
```swift
let config = TealiumConfig(account: "my_account",
                          profile: "my_profile",
                          environment: "dev",
                          modules: [
                              Modules.firebaseDispatcher(),
                              // other modules...
                          ])
```

**Custom configuration** - module with enforced settings:
```swift
let config = TealiumConfig(account: "my_account",
                          profile: "my_profile",
                          environment: "dev",
                          modules: [
                              Modules.firebaseDispatcher(forcingSettings: { builder in
                                  builder.setSessionTimeout(30.minutes)
                                         .setAnalyticsEnabled(true)
                                         .setLogLevel(.min)
                              }),
                              // other modules...
                          ])
```

> **⚠️ Important:** Programmatic settings are deep merged onto local and remote settings and will always take precedence. Only provide programmatic settings for configuration values that you never want to be changed remotely.

## Configuration Options

The Firebase module supports the following configuration options:

| Setting | Key | Description | Default Value |
|---------|-----|-------------|---------------|
| Session timeout | `session_timeout_seconds` | Session timeout in seconds. | *Firebase default* |
| Analytics collection enabled | `analytics_collection_enabled` | Enables or disables Firebase Analytics data collection. When disabled, collection stops but previously collected data is retained. | *Firebase default* |
| Log level | `log_level` | Firebase internal log verbosity — `"min"`, `"error"`, `"warning"`, `"notice"`, `"info"`, `"debug"`, `"max"`. Each string resolves to the matching `FirebaseLoggerLevel` case. | *Firebase default* |

Omitted settings are left untouched on the SDK — only explicitly provided values are applied.

> **Note:** Firebase defines `FirebaseLoggerLevel.min` and `.error` with the same underlying value, as
> it does `.max` and `.debug`. Programmatic `setLogLevel(.min)` therefore persists as `"error"` in the
> settings payload, and `setLogLevel(.max)` as `"debug"`. The effect on Firebase is identical.

## Settings Builders Reference

The Firebase module uses the `FirebaseSettingsBuilder` for configuration. This is an extension of the `DispatcherSettingsBuilder<FirebaseMappings>` which offers common settings like:

- `ModuleSettingsBuilder.setEnabled(_:)`
- `ModuleSettingsBuilder.setOrder(_:)`
- `RuleModuleSettingsBuilder.setRules(_:)`
- `DispatcherSettingsBuilder.setMappings(_:)`

### Firebase-specific methods:

- `FirebaseSettingsBuilder.setSessionTimeout(_:)` - Set the session timeout duration (e.g. `30.minutes`)
- `FirebaseSettingsBuilder.setAnalyticsEnabled(_:)` - Enable or disable analytics collection
- `FirebaseSettingsBuilder.setLogLevel(_:)` - Set the Firebase internal log verbosity

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

Each command is driven by the `FirebaseMappings` system, using the type-safe `FirebaseCommand` and `FirebaseDestination` enums:

```swift
builder.setMappings { mappings in
    mappings.mapCommand(.logEvent).ifValueIn("tealium_event", equals: "log_event")
    mappings.mapFrom("tealium_event", to: .eventName)
    mappings.mapFrom("total", to: .eventParam(AnalyticsParameterValue))
}
```

See the [Mappings](../mappings.html) guide for the shared mapping concepts, and the per-command guides for the full JSON and programmatic mapping reference — including item formats, consent types, and conversion measurement credential priority.

# FirebaseSettingsBuilder
