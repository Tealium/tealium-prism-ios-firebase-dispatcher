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
        
        public static let moduleType: String = FirebaseConstants.moduleType
        public var moduleType: String { Self.moduleType }
        
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
                              logger: context.logger)
        }
        
        public func getEnforcedSettings() -> [DataObject] {
            enforcedSettings
        }
    }
}
