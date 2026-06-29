//
//  ItemsConverterTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 08/05/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import FirebaseAnalytics
@testable import TealiumPrismCore
@testable import TealiumPrismFirebase
import XCTest

final class ItemsConverterTests: XCTestCase {

    // MARK: - Empty Input Tests

    func test_empty_object_returns_nil() throws {
        let input = DataItem(converting: DataObject())

        let result = try ItemsConverter.convert(from: input)

        XCTAssertNil(result)
    }

    func test_empty_array_returns_nil() throws {
        let input = DataItem(value: [] as [DataInput])

        let result = try ItemsConverter.convert(from: input)

        XCTAssertNil(result)
    }

    func test_scalar_input_returns_nil() throws {
        let input = DataItem(value: "not_an_array_or_dict")

        let result = try ItemsConverter.convert(from: input)

        XCTAssertNil(result)
    }

    func test_dict_with_only_scalar_values_returns_nil() throws {
        // compactMapValues skips keys whose values are not arrays — all scalars → empty dict → nil.
        let itemsData: DataObject = [
            AnalyticsParameterItemID: "SKU1",
            AnalyticsParameterPrice: 9.99
        ]
        let input = DataItem(converting: itemsData)

        let result = try ItemsConverter.convert(from: input)

        XCTAssertNil(result)
    }

    // MARK: - Parallel Arrays Tests

    func test_parallel_arrays_transpose_into_item_dictionaries() throws {
        let itemsData: DataObject = [
            AnalyticsParameterItemID: ["SKU1", "SKU2"] as [String],
            AnalyticsParameterPrice: [29.99, 70.00] as [Double]
        ]
        let input = DataItem(converting: itemsData)

        let items = try ItemsConverter.convert(from: input)

        XCTAssertNotNil(items)
        XCTAssertEqual(items?.count, 2)
        XCTAssertEqual(items?[0][AnalyticsParameterItemID] as? String, "SKU1")
        XCTAssertEqual(items?[0][AnalyticsParameterPrice] as? Double, 29.99)
        XCTAssertEqual(items?[1][AnalyticsParameterItemID] as? String, "SKU2")
        XCTAssertEqual(items?[1][AnalyticsParameterPrice] as? Double, 70.00)
    }

    // MARK: - Array of Objects Tests

    func test_array_of_objects_passes_through_unchanged() throws {
        let itemsArray: [DataObject] = [
            [AnalyticsParameterItemID: "SKU1", AnalyticsParameterPrice: 29.99],
            [AnalyticsParameterItemID: "SKU2", AnalyticsParameterPrice: 70.00]
        ]
        let input = DataItem(converting: itemsArray)

        let items = try ItemsConverter.convert(from: input)

        XCTAssertNotNil(items)
        XCTAssertEqual(items?.count, 2)
        XCTAssertEqual(items?[0][AnalyticsParameterItemID] as? String, "SKU1")
        XCTAssertEqual(items?[1][AnalyticsParameterItemID] as? String, "SKU2")
    }

    // MARK: - Error Tests

    func test_mismatched_parallel_arrays_throw_arrayLengthMismatch() {
        let itemsData: DataObject = [
            AnalyticsParameterItemID: ["SKU1", "SKU2"] as [String],
            AnalyticsParameterPrice: [29.99] as [Double]
        ]
        let input = DataItem(converting: itemsData)

        XCTAssertThrowsError(try ItemsConverter.convert(from: input)) { error in
            guard let commandError = error as? CommandError,
                  case .arrayLengthMismatch(_, let count1, _, let count2) = commandError else {
                XCTFail("Expected arrayLengthMismatch but got \(error)")
                return
            }
            XCTAssertNotEqual(count1, count2)
        }
    }
}
