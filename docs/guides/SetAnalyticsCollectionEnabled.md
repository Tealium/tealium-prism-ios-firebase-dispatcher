# SetAnalyticsCollectionEnabled

Enables or disables Firebase Analytics data collection at runtime. When disabled, collection stops but
previously collected data is retained.

**command_name:** `setanalyticscollectionenabled` ·
**Firebase API:** `Analytics.setAnalyticsCollectionEnabled(_:)`

## JSON Mappings

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

## Programmatic

```swift
builder.setMappings { mappings in
    mappings.mapCommand(.setAnalyticsCollectionEnabled)
        .ifValueIn("tealium_event", equals: "privacy_update")
    mappings.mapFrom("analytics_enabled", to: .analyticsEnabled)
}
```

See [Mappings](mappings.html) for the shared mapping concepts used above.
