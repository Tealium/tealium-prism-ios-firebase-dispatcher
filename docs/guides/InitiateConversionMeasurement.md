# InitiateConversionMeasurement

Initiates on-device conversion measurement for Google Ads attribution. You may supply multiple credentials
in a single dispatch — only one is forwarded to Firebase per call, selected by the priority list below.

**command_name:** `initiateconversionmeasurement` ·
**Firebase API:** `Analytics.initiateOnDeviceConversionMeasurement(...)`

> This command is iOS only. The Firebase Android SDK does not expose an on-device conversion measurement
> API, so the Android dispatcher does not implement it.

## Linking the on-device conversion framework

Firebase looks up the `GoogleAdsOnDeviceConversion` framework at runtime, so the linker drops it unless the app
target adds `-ObjC` to **Other Linker Flags** (`OTHER_LDFLAGS`). Without the flag every call fails, and only the
Firebase log shows why: `On-device conversion measurement dependency not linked in`, or `does not support phone
numbers` / `does not support hashed identifiers`. The dispatcher still reports the command as executed, because
Firebase doesn't return a result.

To check the setup, launch the app with the `-FIRDebugEnabled` and `-DebugOnDeviceConversionMeasurement`
arguments. On startup Firebase logs `Conversion service GoogleAdsOnDeviceConversion framework is linked`.

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

A `null` credential counts as not mapped. A mapped credential that is invalid, for example empty or a hash in
the wrong format, fails the command instead of falling back to the next one.

## Plain credentials

Map `email_address` or `phone_number` when the app has the plain value. Firebase hashes it on the device.
The phone number must be in E.164 format, for example `+15555551234`.

## Hashed credentials

Map `hashed_email_address` or `hashed_phone_number` when you hash the value yourself:

1. Normalize the email address or phone number as described in
   [Firebase's on-device measurement guide](https://firebase.google.com/docs/tutorials/ads-ios-on-device-measurement/step-3).
2. Hash its UTF-8 bytes with SHA-256.
3. Map the 32-byte result as 64 hexadecimal characters or 44 characters of standard Base64.

Any other value, such as a plain email address or a SHA-1 hash, fails the command with `invalidValue`. The
dispatcher can't check the normalization: a hash of a value that wasn't normalized is forwarded and never
matches.

```swift
import CryptoKit

let digest = SHA256.hash(data: Data(normalizedEmail.utf8))
let hex = digest.map { String(format: "%02x", $0) }.joined()   // or: Data(digest).base64EncodedString()
teal.track("conversion", data: ["hashed_email": hex])
```

See [Mappings](mappings.html) for the shared mapping concepts used above.
