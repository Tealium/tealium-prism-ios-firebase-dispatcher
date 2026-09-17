//
//  ItemsConverter.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 8/05/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import FirebaseAnalytics
import Foundation
#if canImport(TealiumPrismCore)
import TealiumPrismCore
#else
import TealiumPrism
#endif

/// Converts Tealium item payloads into Firebase-compatible `[[String: Any]]` arrays.
///
/// Firebase's reserved `items` key accepts two input shapes and is always forwarded as an
/// array of dictionaries under `AnalyticsParameterItems`:
///
/// 1. Array of objects (Firebase-ready): each list entry is already a dictionary.
/// 2. Parallel arrays (Tealium convention): each key maps to an array of equal length,
///    or a scalar value treated as a single-element array;
///    the converter transposes them into a list of per-item dictionaries.
///
/// Any array-length mismatch in shape (2) throws `CommandError.arrayLengthMismatch`. In both shapes,
/// unsupported or null property values are dropped individually, and an item left with no properties
/// at all is dropped entirely — Firebase discards empty items itself, so keeping one has no effect and
/// only risks approaching the per-event item limit sooner.
enum ItemsConverter {

    /// Converts Firebase items array from either parallel arrays or array of objects format.
    ///
    /// - Returns: Array of item dictionaries, or nil if no items found.
    /// - Throws: `CommandError.arrayLengthMismatch` if item arrays have mismatched lengths.
    static func convert(from itemsData: DataItem) throws(CommandError) -> [[String: Any]]? {
        var items: [[String: Any]] = []
        if let arrayOfObjects = itemsData.getDataArray() {
            items = convertArrayOfObjects(arrayOfObjects)
        } else if let objectOfArrays = itemsData.getDataDictionary() {
            items = try convertParallelArrays(objectOfArrays)
        }
        return items.isEmpty ? nil : items
    }

    /// Converts array of objects to Firebase items format.
    /// Input:  [DataItem(dict: {"item_id": "SKU1"}), DataItem(dict: {"item_id": "SKU2"})]
    /// Output: [["item_id": "SKU1"], ["item_id": "SKU2"]]
    private static func convertArrayOfObjects(_ arrayOfObjects: [DataItem]) -> [[String: Any]] {
        return arrayOfObjects.compactMap { itemData -> [String: Any]? in
            // Drop non-dict entries outright.
            guard let itemDict = itemData.getDataDictionary() else {
                return nil
            }

            // Drop properties that don't resolve to a real value, then drop the whole item if
            // nothing is left — checking emptiness on the input dict alone would miss items whose
            // only properties are null (e.g. `{"discount": null}`).
            let item = itemDict.reduce(into: [String: Any]()) { result, pair in
                let value = pair.value.toDataInput()
                if !(value is NSNull) {
                    result[pair.key] = value
                }
            }
            return item.isEmpty ? nil : item
        }
    }

    /// Converts parallel arrays to array of item dictionaries.
    /// Input:  { "item_id": ["SKU1", "SKU2"], "item_name": ["P1", "P2"] }
    /// Output: [["item_id": "SKU1", "item_name": "P1"], ["item_id": "SKU2", "item_name": "P2"]]
    private static func convertParallelArrays(_ parallelArrays: [String: DataItem]) throws(CommandError) -> [[String: Any]] {
        let arrays = extractArrays(from: parallelArrays)

        guard let itemCount = arrays.values.map(\.count).max(), itemCount > 0 else {
            return []
        }

        if let mismatch = arrays.first(where: { $0.value.count != itemCount }),
           let expected = arrays.first(where: { $0.value.count == itemCount }) {
            throw CommandError.arrayLengthMismatch(
                array1: expected.key,
                count1: expected.value.count,
                array2: mismatch.key,
                count2: mismatch.value.count
            )
        }

        // Drop items left with no properties once nulls are removed — same rule as array-of-objects.
        return (0..<itemCount).compactMap { index in
            let item = makeItem(from: arrays, at: index)
            return item.isEmpty ? nil : item
        }
    }

    private static func makeItem(from arrays: [String: [DataInput]], at index: Int) -> [String: Any] {
        arrays.reduce(into: [String: Any]()) { result, keyValue in
            let value = keyValue.value[index]
            if !(value is NSNull) {
                result[keyValue.key] = value
            }
        }
    }

    private static func extractArrays(from dict: [String: DataItem]) -> [String: [DataInput]] {
        dict.compactMapValues { item in
            if let array = item.getDataArray() {
                return array.map { $0.toDataInput() }
            }
            // Scalar treated as a single-element array so {"item_id": "SKU1"} produces one item
            // without requiring the caller to wrap scalars in arrays.
            let scalar = item.toDataInput()
            return scalar is NSNull ? nil : [scalar]
        }
    }
}
