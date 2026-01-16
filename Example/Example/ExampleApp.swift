//
//  ExampleApp.swift
//  Example
//
//  Created by Sebastian Krajna on 03/12/2025.
//

import SwiftUI
import TealiumPrismCore
import TealiumPrismFirebase

@main
struct ExampleApp: App {
    
    init() {
        // Initialize Tealium with Firebase dispatcher on app launch
        TealiumHelper.shared.startTealium()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
