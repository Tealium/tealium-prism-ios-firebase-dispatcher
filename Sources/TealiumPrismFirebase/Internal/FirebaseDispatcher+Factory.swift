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
        
        public let allowsMultipleInstances: Bool = true
        
        let enforcedSettings: [DataObject]
        typealias SettingsBuilderBlock = Modules.EnforcingSettings<FirebaseSettingsBuilder>
        
        public init(forcingSettings blocks: [SettingsBuilderBlock?] = []) {
            self.enforcedSettings = blocks.compactMap { block in block?(FirebaseSettingsBuilder()).build() }
        }
        
        public func create(moduleId: String, 
                          context: TealiumContext, 
                          moduleConfiguration: DataObject) -> FirebaseDispatcher? {
            FirebaseDispatcher(moduleId: moduleId, 
                              context: context,
                              moduleConfiguration: moduleConfiguration)
        }
        
        public func getEnforcedSettings() -> [DataObject] {
            enforcedSettings
        }
    }
}
