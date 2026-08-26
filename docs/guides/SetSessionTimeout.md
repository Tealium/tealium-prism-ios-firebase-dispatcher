# SetSessionTimeout

Overrides the session timeout interval at runtime, replacing whatever was applied at initialization.

**command_name:** `setsessiontimeout` · **Firebase API:** `Analytics.setSessionTimeoutInterval(_:)`

## JSON Mappings

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

## Programmatic

```swift
builder.setMappings { mappings in
    mappings.mapCommand(.setSessionTimeout).ifValueIn("tealium_event", equals: "session_config")
    mappings.mapFrom("session_timeout_seconds", to: .sessionTimeout)
}
```

> The payload value is expressed in seconds, matching the cross-platform schema and the
> `session_timeout_seconds` initialization setting.

See [Mappings](mappings.html) for the shared mapping concepts used above.
