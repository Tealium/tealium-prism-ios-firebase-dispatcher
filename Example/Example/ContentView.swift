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
                    
                    // MARK: - LogEventCommand
                    Group {
                        Text("LogEvent Command")
                            .font(.headline)
                            .foregroundColor(.tealBlue)
                        
                        TealiumTextButton(title: "Send Purchase Event") {
                            TealiumHelper.shared.logComprehensivePurchaseEvent()
                        }

                        TealiumTextButton(title: "Send Purchase Event (log_event)") {
                            TealiumHelper.shared.logPurchaseEvent()
                        }
                    }
                    
                    Divider().padding(.vertical)
                    
                    // MARK: - SetUserIdCommand
                    Group {
                        Text("SetUserId Command")
                            .font(.headline)
                            .foregroundColor(.tealBlue)
                        
                        TealiumTextButton(title: "Set User ID") {
                            TealiumHelper.shared.setUserId()
                        }
                        
                        TealiumTextButton(title: "Clear User ID") {
                            TealiumHelper.shared.clearUserId()
                        }
                    }
                    
                    Divider().padding(.vertical)
                    
                    // MARK: - SetUserPropertyCommand
                    Group {
                        Text("SetUserProperty Command")
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
                    
                    // MARK: - SetUserPropertiesCommand
                    Group {
                        Text("SetUserProperties Command")
                            .font(.headline)
                            .foregroundColor(.tealBlue)
                        
                        TealiumTextButton(title: "Set Multiple Properties") {
                            TealiumHelper.shared.setMultipleUserProperties()
                        }
                        
                        TealiumTextButton(title: "Clear Multiple Properties") {
                            TealiumHelper.shared.clearMultipleUserProperties()
                        }
                    }
                    
                    Divider().padding(.vertical)
                    
                    // MARK: - SetDefaultParametersCommand
                    Group {
                        Text("SetDefaultParameters Command")
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
                    
                    // MARK: - SetConsentCommand
                    Group {
                        Text("SetConsent Command")
                            .font(.headline)
                            .foregroundColor(.tealBlue)
                        
                        TealiumTextButton(title: "Grant All Consent") {
                            TealiumHelper.shared.grantAllConsent()
                        }
                        
                        TealiumTextButton(title: "Deny All Consent") {
                            TealiumHelper.shared.denyAllConsent()
                        }
                    }
                    
                    Divider().padding(.vertical)
                    
                    // MARK: - ResetDataCommand
                    Group {
                        Text("ResetData Command")
                            .font(.headline)
                            .foregroundColor(.tealBlue)
                        
                        TealiumTextButton(title: "Reset Firebase Data") {
                            TealiumHelper.shared.resetFirebaseData()
                        }
                    }
                    
                    Divider().padding(.vertical)
                    
                    // MARK: - SetSessionTimeoutCommand
                    Group {
                        Text("SetSessionTimeout Command")
                            .font(.headline)
                            .foregroundColor(.tealBlue)
                        
                        TealiumTextButton(title: "Set to 1 Hour") {
                            TealiumHelper.shared.updateSessionTimeout()
                        }
                        
                        TealiumTextButton(title: "Reset to Default (30 min)") {
                            TealiumHelper.shared.resetSessionTimeout()
                        }
                    }
                    
                    Divider().padding(.vertical)
                    
                    // MARK: - SetAnalyticsCollectionEnabledCommand
                    Group {
                        Text("SetAnalyticsCollectionEnabled")
                            .font(.headline)
                            .foregroundColor(.tealBlue)
                        
                        TealiumTextButton(title: "Enable Analytics") {
                            TealiumHelper.shared.enableAnalytics()
                        }
                        
                        TealiumTextButton(title: "Disable Analytics") {
                            TealiumHelper.shared.disableAnalytics()
                        }
                    }
                    
                    Divider().padding(.vertical)
                    
                    // MARK: - InitiateConversionMeasurementCommand
                    Group {
                        Text("InitiateConversionMeasurement")
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
