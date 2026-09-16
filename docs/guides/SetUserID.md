# SetUserID

Associates analytics data with a specific user.

**command_name:** `setuserid` · **Firebase API:** `Analytics.setUserID(_:)`

## JSON Mappings

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

## Programmatic

```swift
builder.setMappings { mappings in
    mappings.mapCommand(.setUserId).ifValueIn("tealium_event", equals: "user_login")
    mappings.mapFrom("user_id", to: .userId)
}
```

> Passing an empty string clears the user ID. Use of this field must comply with Google's Privacy Policy.

See [Mappings](mappings.html) for the shared mapping concepts used above.
