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
        // APPROACH 1 (Recommended): Automatic Firebase configuration
        // Firebase is configured automatically by Tealium with settings from TealiumHelper
        // Use this approach if you're using Firebase ONLY through Tealium
        TealiumHelper.shared.startTealium()
        
        // APPROACH 2 (Advanced): Manual Firebase configuration
        // Use this approach if you need to use Firebase APIs directly in your app
        // (e.g., Crashlytics, Remote Config, or direct Analytics calls)
        //
        // FirebaseConfiguration.shared.setLoggerLevel(.debug)  // Optional: for complete logging
        // FirebaseApp.configure()  // Configure Firebase manually
        // TealiumHelper.shared.startTealium()  // Tealium's configure() will be a no-op
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
