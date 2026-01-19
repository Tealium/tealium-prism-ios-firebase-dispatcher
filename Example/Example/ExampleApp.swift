//
//  ExampleApp.swift
//  Example
//
//  Created by Sebastian Krajna on 03/12/2025.
//

import SwiftUI
import TealiumPrismCore
import TealiumPrismFirebase
import FirebaseCore

@main
struct ExampleApp: App {
    
    init() {
        // Configure Firebase before initializing Tealium
        FirebaseApp.configure()
        
        // Initialize Tealium with Firebase dispatcher on app launch
        TealiumHelper.shared.startTealium()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
