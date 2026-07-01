//
//  ItemsConverter.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 8/05/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import FirebaseAnalytics
import Foundation
import TealiumPrismCore

/// Converts Tealium item payloads into Firebase-compatible `[[String: Any]]` arrays.
///
/// Firebase's reserved `items` key accepts two input shapes and is always forwarded as an
/// array of dictionaries under `AnalyticsParameterItems`:
///
/// 1. Array of objects (Firebase-ready): each list entry is already a dictionary.
/// 2. Parallel arrays (Tealium convention): each key maps to an array of equal length;
///    the converter transposes them into a list of per-item dictionaries.
///
/// Any array-length mismatch in shape (2) throws `CommandError.arrayLengthMismatch`.
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
        return arrayOfObjects.compactMap { itemData in
            guard let itemDict = itemData.getDataDictionary() else {
                return nil
            }

            return itemDict.reduce(into: [String: Any]()) { result, pair in
                result[pair.key] = pair.value.toDataInput()
            }
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

        return (0..<itemCount).map { index in
            makeItem(from: arrays, at: index)
        }
    }

    private static func makeItem(from arrays: [String: [DataInput]], at index: Int) -> [String: Any] {
        arrays.reduce(into: [String: Any]()) { result, keyValue in
            result[keyValue.key] = keyValue.value[index]
        }
    }

    private static func extractArrays(from dict: [String: DataItem]) -> [String: [DataInput]] {
        dict.compactMapValues { $0.getDataArray()?.map { $0.toDataInput() } }
    }
}
