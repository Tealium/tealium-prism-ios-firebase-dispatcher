# SetConsent

Configures end-user consent state for device identifiers. Should be applied before logging any events.

**command_name:** `setconsent` · **Firebase API:** `Analytics.setConsent(_:)`

## JSON Mappings

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

## Programmatic

```swift
builder.setMappings { mappings in
    mappings.mapCommand(.setConsent).ifValueIn("tealium_event", equals: "consent_update")
    mappings.mapFrom("ad_storage_consent", to: .consentSetting(.adStorage))
    mappings.mapFrom("analytics_storage_consent", to: .consentSetting(.analyticsStorage))
}
```

## Consent types

| Consent Type | `FirebaseDestination` | Status Values |
|---|---|---|
| `ad_storage` | `.consentSetting(.adStorage)` | `granted`, `denied` |
| `analytics_storage` | `.consentSetting(.analyticsStorage)` | `granted`, `denied` |
| `ad_user_data` | `.consentSetting(.adUserData)` | `granted`, `denied` |
| `ad_personalization` | `.consentSetting(.adPersonalization)` | `granted`, `denied` |

> Type and status strings are matched case-insensitively. An unknown consent type or status is rejected
> and the command fails, surfacing the configuration mistake instead of silently dropping the entry. A
> `consent_settings` object that resolves to no valid entries also fails. Valid types: `ad_storage`,
> `analytics_storage`, `ad_user_data`, `ad_personalization`. Valid statuses: `granted`, `denied`.

See [Mappings](mappings.html) for the shared mapping concepts used above.
