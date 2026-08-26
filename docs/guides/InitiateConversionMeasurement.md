# InitiateConversionMeasurement

Initiates on-device conversion measurement for Google Ads attribution. You may supply multiple credentials
in a single dispatch — only one is forwarded to Firebase per call, selected by the priority list below.

**command_name:** `initiateconversionmeasurement` ·
**Firebase API:** `Analytics.initiateOnDeviceConversionMeasurement(...)`

> This command is iOS only. The Firebase Android SDK does not expose an on-device conversion measurement
> API, so the Android dispatcher does not implement it.

## JSON Mappings

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

## Programmatic

```swift
builder.setMappings { mappings in
    mappings.mapCommand(.initiateConversionMeasurement)
        .ifValueIn("tealium_event", equals: "conversion")
    mappings.mapFrom("hashed_email", to: .conversionHashedEmail)
}
```

## Credential priority

When multiple credentials are mapped, the dispatcher picks exactly one according to this priority (first
match wins):

1. `hashed_email_address` → `.conversionHashedEmail`
2. `hashed_phone_number` → `.conversionHashedPhone`
3. `email_address` → `.conversionEmail`
4. `phone_number` → `.conversionPhone`

> `hashed_email_address` and `hashed_phone_number` must be **Base64-encoded SHA-256 hashes**. Passing a
> plain string will be rejected.

See [Mappings](mappings.html) for the shared mapping concepts used above.
