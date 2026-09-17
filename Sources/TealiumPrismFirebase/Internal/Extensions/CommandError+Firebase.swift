//
//  CommandError+Firebase.swift
//  TealiumPrismFirebase
//
//  Created by Enrico Zannini on 18/06/2026.
//

import Foundation
#if canImport(TealiumPrismCore)
import TealiumPrismCore
#else
import TealiumPrism
#endif

extension CommandError {
    static func missingParameter(_ parameter: FirebaseDestination) -> Self {
        .missingParameter(parameter.path.render())
    }

    static func invalidParameterType(parameter: FirebaseDestination, expectedType: String) -> Self {
        .invalidParameterType(parameter: parameter.path.render(), expectedType: expectedType)
    }

    static func emptyParameter(_ parameter: FirebaseDestination) -> Self {
        .emptyParameter(parameter.path.render())
    }

    static func emptyArray(_ parameter: FirebaseDestination) -> Self {
        .emptyArray(parameter.path.render())
    }

    static func noValidParameters(expected: [FirebaseDestination]) -> Self {
        .noValidParameters(expected: expected.map { $0.path.render() })
    }
}
