//
//  DataItemExtractor+Firebase.swift
//  TealiumPrismFirebase
//
//  Created by Enrico Zannini on 18/06/2026.
//

import Foundation
import TealiumPrismCore

extension DataItemExtractor {
    func requireDataItem(_ destination: FirebaseDestination) throws(CommandError) -> DataItem {
        guard let item = extractDataItem(path: destination.path) else {
            throw .missingParameter(destination)
        }
        return item
    }

    func requireDataDictionary(_ destination: FirebaseDestination) throws(CommandError) -> [String: DataItem] {
        let item = try requireDataItem(destination)
        guard let value = item.getDataDictionary() else {
            throw .invalidParameterType(parameter: destination, expectedType: "\([String: DataItem].self)")
        }
        return value
    }

    func require<T: DataInput>(_ destination: FirebaseDestination, as type: T.Type) throws(CommandError) -> T {
        let item = try requireDataItem(destination)
        guard let value = item.get(as: type) else {
            throw .invalidParameterType(parameter: destination, expectedType: "\(T.self)")
        }
        return value
    }

    func require<T>(_ destination: FirebaseDestination, converter: any DataItemConverter<T>) throws(CommandError) -> T {
        let item = try requireDataItem(destination)
        guard let value = item.getConvertible(converter: converter) else {
            throw .invalidParameterType(parameter: destination, expectedType: "\(T.self)")
        }
        return value
    }
}
