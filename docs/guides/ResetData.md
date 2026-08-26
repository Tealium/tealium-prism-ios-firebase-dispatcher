# ResetData

Clears all analytics data for this app instance from the device and resets the app instance ID. Use on
user logout or when privacy regulations require data deletion.

**command_name:** `resetdata` · **Firebase API:** `Analytics.resetAnalyticsData()`

## JSON Mappings

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

This command takes no payload fields, so the `command_name` mapping is the only one required.

## Programmatic

```swift
builder.setMappings { mappings in
    mappings.mapCommand(.resetData).ifValueIn("tealium_event", equals: "user_logout")
}
```

See [Mappings](mappings.html) for the shared mapping concepts used above.
