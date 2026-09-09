# SetDefaultParameters

Sets parameters that are automatically appended to every subsequent event. Useful for app-wide context
such as version or locale. Defaults persist across app runs and have lower precedence than event-level
parameters.

**command_name:** `setdefaultparameters` · **Firebase API:** `Analytics.setDefaultEventParameters(_:)`

## JSON Mappings

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

## Programmatic

```swift
builder.setMappings { mappings in
    mappings.mapCommand(.setDefaultParameters).ifValueIn("tealium_event", equals: "app_launch")
    mappings.mapFrom("app_version", to: .defaultParam("version"))
    mappings.mapFrom("app_language", to: .defaultParam("language"))
}
```

## Clearing defaults

To clear all previously set default parameters, dispatch the `setdefaultparameters` command with no
`parameters` key in the mapped output — that is, with none of the source keys resolving to a value.

Map a dedicated event to the command, then dispatch it with none of the parameter source keys present:

```json
{
    "destination": { "key": "command_name" },
    "parameters": {
        "reference": { "key": "tealium_event" },
        "filter": { "value": "clear_defaults" },
        "map_to": { "value": "setdefaultparameters" }
    }
}
```

```swift
teal.track("clear_defaults", data: [:])
```

Because `data` carries none of the `parameters.*` source keys (`app_version`, `app_language`), no
parameters resolve and Firebase clears all default event parameters.

> The `parameters` key must be **absent entirely**. An empty `parameters` object is a deliberate no-op,
> so a partially-populated dispatch can never wipe your defaults by accident.

See [Mappings](mappings.html) for the shared mapping concepts used above.
