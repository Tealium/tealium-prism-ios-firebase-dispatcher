//
//  ContentView.swift
//  Example
//
//  Created by Sebastian Krajna on 03/12/2025.
//

import SwiftUI
import Combine
import TealiumPrismCore

struct ContentView: View {
    @State private var tealiumStarted: Bool = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    
                    Divider().padding(.vertical)
                    
                    // MARK: - 1. LogEventCommand
                    Group {
                        Text("1. LogEvent Command")
                            .font(.headline)
                            .foregroundColor(.tealBlue)
                        
                        TealiumTextButton(title: "Simple Event") {
                            TealiumHelper.shared.logSimpleEvent()
                        }
                        
                        TealiumTextButton(title: "Event + Parameters") {
                            TealiumHelper.shared.logEventWithParameters()
                        }
                        
                        TealiumTextButton(title: "E-commerce + Items") {
                            TealiumHelper.shared.logEcommerceEvent()
                        }
                        
                        TealiumTextButton(title: "Invalid Characters") {
                            TealiumHelper.shared.logEventWithInvalidChars()
                        }
                        
                        TealiumTextButton(title: "Reserved Name") {
                            TealiumHelper.shared.logEventWithReservedName()
                        }
                        
                        TealiumTextButton(title: "Long Name (>40 chars)") {
                            TealiumHelper.shared.logEventWithLongName()
                        }
                        
                        TealiumTextButton(title: "Max Parameters (105)") {
                            TealiumHelper.shared.logEventWithMaxParams()
                        }
                        
                        TealiumTextButton(title: "Max Items (105)") {
                            TealiumHelper.shared.logEventWithMaxItems()
                        }
                    }
                    
                    Divider().padding(.vertical)
                    
                    // MARK: - 2. SetUserIdCommand
                    Group {
                        Text("2. SetUserId Command")
                            .font(.headline)
                            .foregroundColor(.tealBlue)
                        
                        TealiumTextButton(title: "Set User ID") {
                            TealiumHelper.shared.setUserId()
                        }
                        
                        TealiumTextButton(title: "Clear User ID") {
                            TealiumHelper.shared.clearUserId()
                        }
                        
                        TealiumTextButton(title: "User ID >256 chars") {
                            TealiumHelper.shared.setUserIdTooLong()
                        }
                    }
                    
                    Divider().padding(.vertical)
                    
                    // MARK: - 3. SetUserPropertyCommand
                    Group {
                        Text("3. SetUserProperty Command")
                            .font(.headline)
                            .foregroundColor(.tealBlue)
                        
                        TealiumTextButton(title: "Set Property") {
                            TealiumHelper.shared.setUserProperty()
                        }
                        
                        TealiumTextButton(title: "Clear Property") {
                            TealiumHelper.shared.clearUserProperty()
                        }
                    }
                    
                    Divider().padding(.vertical)
                    
                    // MARK: - 4. SetUserPropertiesCommand
                    Group {
                        Text("4. SetUserProperties Command")
                            .font(.headline)
                            .foregroundColor(.tealBlue)
                        
                        TealiumTextButton(title: "Set Multiple Properties") {
                            TealiumHelper.shared.setMultipleUserProperties()
                        }
                        
                        TealiumTextButton(title: "Mismatched Arrays") {
                            TealiumHelper.shared.setUserPropertiesMismatchedArrays()
                        }
                        
                        TealiumTextButton(title: "Empty Arrays") {
                            TealiumHelper.shared.setUserPropertiesEmpty()
                        }
                    }
                    
                    Divider().padding(.vertical)
                    
                    // MARK: - 5. SetDefaultParametersCommand
                    Group {
                        Text("5. SetDefaultParameters Command")
                            .font(.headline)
                            .foregroundColor(.tealBlue)
                        
                        TealiumTextButton(title: "Set Default Params") {
                            TealiumHelper.shared.setDefaultParameters()
                        }
                        
                        TealiumTextButton(title: "Clear Default Params") {
                            TealiumHelper.shared.clearDefaultParameters()
                        }
                    }
                    
                    Divider().padding(.vertical)
                    
                    // MARK: - 6. SetConsentCommand
                    Group {
                        Text("6. SetConsent Command")
                            .font(.headline)
                            .foregroundColor(.tealBlue)
                        
                        TealiumTextButton(title: "Grant All Consent") {
                            TealiumHelper.shared.grantAllConsent()
                        }
                        
                        TealiumTextButton(title: "Deny All Consent") {
                            TealiumHelper.shared.denyAllConsent()
                        }
                        
                        TealiumTextButton(title: "Mixed Consent") {
                            TealiumHelper.shared.mixedConsent()
                        }
                        
                        TealiumTextButton(title: "Invalid Value") {
                            TealiumHelper.shared.invalidConsentValue()
                        }
                    }
                    
                    Divider().padding(.vertical)
                    
                    // MARK: - 7. ResetDataCommand
                    Group {
                        Text("7. ResetData Command")
                            .font(.headline)
                            .foregroundColor(.tealBlue)
                        
                        TealiumTextButton(title: "Reset Firebase Data") {
                            TealiumHelper.shared.resetFirebaseData()
                        }
                    }
                    
                    Divider().padding(.vertical)
                    
                    // MARK: - 8. SetSessionTimeoutCommand
                    Group {
                        Text("8. SetSessionTimeout Command")
                            .font(.headline)
                            .foregroundColor(.tealBlue)
                        
                        TealiumTextButton(title: "Update Timeout (3600)") {
                            TealiumHelper.shared.updateSessionTimeout()
                        }
                        
                        TealiumTextButton(title: "Timeout as String") {
                            TealiumHelper.shared.updateSessionTimeoutString()
                        }
                    }
                    
                    Divider().padding(.vertical)
                    
                    // MARK: - 9. SetAnalyticsCollectionEnabledCommand
                    Group {
                        Text("9. SetAnalyticsCollectionEnabled")
                            .font(.headline)
                            .foregroundColor(.tealBlue)
                        
                        TealiumTextButton(title: "Enable Analytics") {
                            TealiumHelper.shared.enableAnalytics()
                        }
                        
                        TealiumTextButton(title: "Disable Analytics") {
                            TealiumHelper.shared.disableAnalytics()
                        }
                        
                        TealiumTextButton(title: "Enable (String)") {
                            TealiumHelper.shared.enableAnalyticsString()
                        }
                        
                        TealiumTextButton(title: "Enable (Int)") {
                            TealiumHelper.shared.enableAnalyticsInt()
                        }
                    }
                    
                    Divider().padding(.vertical)
                    
                    // MARK: - 10. InitiateConversionMeasurementCommand
                    Group {
                        Text("10. InitiateConversionMeasurement")
                            .font(.headline)
                            .foregroundColor(.tealBlue)
                        
                        TealiumTextButton(title: "With Email") {
                            TealiumHelper.shared.conversionWithEmail()
                        }
                        
                        TealiumTextButton(title: "With Phone") {
                            TealiumHelper.shared.conversionWithPhone()
                        }
                        
                        TealiumTextButton(title: "With Hashed Email") {
                            TealiumHelper.shared.conversionWithHashedEmail()
                        }
                        
                        TealiumTextButton(title: "With Hashed Phone") {
                            TealiumHelper.shared.conversionWithHashedPhone()
                        }
                        
                        TealiumTextButton(title: "No Parameters") {
                            TealiumHelper.shared.conversionWithoutParams()
                        }
                        
                        TealiumTextButton(title: "Empty Email") {
                            TealiumHelper.shared.conversionWithEmptyEmail()
                        }
                    }
                    
                    Divider().padding(.vertical)
                    
                    // MARK: - Developer Tools
                    Group {
                        Text("Developer Tools")
                            .font(.headline)
                            .foregroundColor(.tealBlue)
                        
                        TealiumTextButton(title: tealiumStarted ? "Stop Tealium" : "Start Tealium") {
                            if tealiumStarted {
                                TealiumHelper.shared.stopTealium()
                            } else {
                                TealiumHelper.shared.startTealium()
                            }
                            tealiumStarted.toggle()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Firebase Commands")
        }
    }
}

#Preview {
    ContentView()
}
