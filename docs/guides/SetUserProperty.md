# SetUserProperty

Sets one or more user properties. Properties persist across sessions.

The dispatcher forwards every resolved name/value pair to the SDK as-is. Firebase enforces its own quotas
on user property names and values — consult the Firebase Analytics documentation for the current ones.

**command_name:** `setuserproperty` · **Firebase API:** `Analytics.setUserProperty(_:forName:)`

## JSON Mappings

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

To set multiple properties in a single dispatch, map source keys whose values are arrays. Both arrays must
have the same length — each index pairs one name with one value:

```json
{
    "property_name": ["subscription_tier", "user_level"],
    "property_value": ["premium", "expert"]
}
```

## Programmatic

```swift
builder.setMappings { mappings in
    mappings.mapCommand(.setUserProperty).ifValueIn("tealium_event", equals: "profile_update")
    mappings.mapFrom("property_name", to: .userPropertyName)
    mappings.mapFrom("property_value", to: .userPropertyValue)
}
```

> Numbers and booleans are sent as strings (`42` becomes `"42"`). An empty string, `null`, or a value that
> can't be converted, such as an object, as `property_value` removes that property from Firebase. Array names that can't be converted, such as `null`
> or an object, are skipped.
>
> The command fails if:
> - `property_name` is an object instead of a value or an array,
> - the name and value arrays have different lengths, or
> - none of the names can be converted.

See [Mappings](mappings.html) for the shared mapping concepts used above.
