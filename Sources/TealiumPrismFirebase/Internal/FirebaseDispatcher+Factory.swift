//
//  FirebaseDispatcher+Factory.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 9/01/2026.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

extension FirebaseDispatcher {
    
    public class Factory: ModuleFactory {
        
        let moduleType: String = Modules.Types.firebaseDispatcher
        
        /// Firebase Analytics only supports a single shared instance.
        /// Multiple dispatcher instances would all write to the same Firebase Analytics backend.
        public let allowsMultipleInstances: Bool = false
        
        let enforcedSettings: DataObject?
        typealias SettingsBuilderBlock = Modules.EnforcingSettings<FirebaseSettingsBuilder>
        
        public init(forcingSettings block: SettingsBuilderBlock? = nil) {
            self.enforcedSettings = block?(FirebaseSettingsBuilder()).build()
        }
        
        public func create(moduleId: String, 
                          context: TealiumContext, 
                          moduleConfiguration: DataObject) -> FirebaseDispatcher? {
            FirebaseDispatcher(moduleId: moduleId, 
                              context: context,
                              moduleConfiguration: moduleConfiguration)
        }
        
        public func getEnforcedSettings() -> [DataObject] {
            enforcedSettings.map { [$0] } ?? []
        }
    }
}
