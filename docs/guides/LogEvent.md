# LogEvent

Logs an event to Firebase Analytics. Supports predefined Firebase events and custom events, with optional
parameters and nested item arrays for e-commerce.

**command_name:** `logevent` · **Firebase API:** `Analytics.logEvent(_:parameters:)`

There are two mapping approaches for this command.

## Approach 1 — Explicit event name

`tealium_event` identifies the command type. The Firebase event name is passed as a separate `event_name`
field in the dispatch data. This is consistent with all other commands.

**Dispatch data:**
```swift
teal.track("log_event", data: [
    "event_name": "purchase",
    "total": 99.99,
    "currency": "USD"
])
```

**JSON Mappings:**
```json
{
    "destination": { "key": "command_name" },
    "parameters": {
        "reference": { "key": "tealium_event" },
        "filter": { "value": "log_event" },
        "map_to": { "value": "logevent" }
    }
},
{
    "destination": { "path": "event_name" },
    "parameters": { "reference": { "key": "event_name" } }
},
{
    "destination": { "path": "parameters.value" },
    "parameters": { "reference": { "key": "total" } }
},
{
    "destination": { "path": "parameters.currency" },
    "parameters": { "reference": { "key": "currency" } }
}
```

**Programmatic:**
```swift
builder.setMappings { mappings in
    mappings.mapCommand(.logEvent).ifValueIn("tealium_event", equals: "log_event")
    mappings.mapFrom("event_name", to: .eventName)
    mappings.mapFrom("total", to: .eventParam(AnalyticsParameterValue))
    mappings.mapFrom("currency", to: .eventParam(AnalyticsParameterCurrency))
}
```

## Approach 2 — Shortcut: `tealium_event` as event name

`tealium_event` is both the trigger and the Firebase event name. No separate `event_name` field is needed.
Useful when your Tealium event names already match Firebase event names.

**Dispatch data:**
```swift
teal.track("purchase", data: [
    "total": 99.99,
    "currency": "USD"
])
```

**JSON Mappings:**
```json
{
    "destination": { "key": "command_name" },
    "parameters": {
        "reference": { "key": "tealium_event" },
        "filter": { "value": "purchase" },
        "map_to": { "value": "logevent" }
    }
},
{
    "destination": { "path": "event_name" },
    "parameters": { "reference": { "key": "tealium_event" } }
},
{
    "destination": { "path": "parameters.value" },
    "parameters": { "reference": { "key": "total" } }
},
{
    "destination": { "path": "parameters.currency" },
    "parameters": { "reference": { "key": "currency" } }
}
```

**Programmatic:**
```swift
builder.setMappings { mappings in
    mappings.mapCommand(.logEvent).ifValueIn("tealium_event", equals: "purchase")
    mappings.mapFrom("tealium_event", to: .eventName)
    mappings.mapFrom("total", to: .eventParam(AnalyticsParameterValue))
    mappings.mapFrom("currency", to: .eventParam(AnalyticsParameterCurrency))
}
```

> With Approach 2, each Firebase event name requires its own `command_name` filter mapping. Approach 1
> uses a single `"log_event"` filter for all events. To forward *every* tracked event, replace the filter
> with `mappings.mapCommand(.logEvent).forAllEvents()`.

## Item formats

Items under `parameters.items` support two equivalent formats.

**Parallel arrays** (Tealium convention — each property is an array of values per item):

```json
"items": {
    "item_id":   ["SKU001", "SKU002"],
    "item_name": ["Widget", "Gadget"],
    "price":     [29.99, 70.00]
}
```

**Array of objects** (Firebase-ready format):

```json
"items": [
    { "item_id": "SKU001", "item_name": "Widget", "price": 29.99 },
    { "item_id": "SKU002", "item_name": "Gadget", "price": 70.00 }
]
```

Both formats produce identical Firebase output. Map individual item properties with `.itemParam(_:)`:

```swift
mappings.mapFrom("product_ids", to: .itemParam(AnalyticsParameterItemID))
mappings.mapFrom("product_names", to: .itemParam(AnalyticsParameterItemName))
```

Handling details:
- In the parallel-arrays format, all arrays must have the same length; a mismatch fails the command.
- A scalar value is treated as a single-element array, so `{"item_id": "SKU001"}` yields one item.
- In the array-of-objects format, entries that are not objects are dropped.
- In both formats, an unsupported or null property value is dropped individually, and an item left with
  no properties at all (e.g. `{"discount": null}`) is dropped entirely. Firebase discards empty items
  anyway, so keeping one would only push the event closer to the per-event item limit.

See [Mappings](mappings.html) for the shared mapping concepts used above.
