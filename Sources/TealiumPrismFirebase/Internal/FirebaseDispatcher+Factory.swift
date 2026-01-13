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
    
    /// Factory for creating FirebaseDispatcher instances
    public class Factory: ModuleFactory {
        
        public static let moduleType: String = FirebaseConstants.moduleType
        public var moduleType: String { Self.moduleType }
        
        public let allowsMultipleInstances: Bool = false
        
        private let enforcedSettings: DataObject?
        
        /// Initialize with optional enforced settings
        /// - Parameter enforcedSettings: Optional settings to enforce on all created instances
        public init(enforcedSettings: DataObject? = nil) {
            self.enforcedSettings = enforcedSettings
        }
        
        /// Create a new FirebaseDispatcher instance
        public func create(moduleId: String, 
                          context: TealiumContext, 
                          moduleConfiguration: DataObject) -> FirebaseDispatcher? {
            FirebaseDispatcher(moduleId: moduleId, 
                              logger: context.logger)
        }
        
        /// Return enforced settings if configured
        public func getEnforcedSettings() -> [DataObject] {
            if let settings = enforcedSettings {
                return [settings]
            }
            return []
        }
    }
}
