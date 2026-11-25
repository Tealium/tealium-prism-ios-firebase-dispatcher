//
//  CommandError+Firebase.swift
//  TealiumPrismFirebase
//
//  Created by Enrico Zannini on 18/06/2026.
//

import TealiumPrismCore

extension CommandError {
    static func noValidParameters(expected: [FirebaseDestination]) -> Self {
        .noValidParameters(expected: expected.map { $0.path.render() })
    }
}
