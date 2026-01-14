//
//  MockLogger.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 14/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismCore
import Foundation

/// Mock implementation of LoggerProtocol for testing.
/// Captures all log messages for verification.
class MockLogger: LoggerProtocol {
    
    // MARK: - Log Storage
    
    struct LogEntry {
        let level: LogLevel
        let category: String
        let message: String
    }
    
    private(set) var logs: [LogEntry] = []
    
    // MARK: - LoggerProtocol
    
    func shouldLog(level: LogLevel, completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    func log(level: LogLevel, category: String, _ messageProvider: @autoclosure @escaping () -> String) {
        logs.append(LogEntry(level: level, category: category, message: messageProvider()))
    }
    
    // MARK: - Helpers
    
    var debugLogs: [LogEntry] {
        logs.filter { $0.level == .debug }
    }
    
    var infoLogs: [LogEntry] {
        logs.filter { $0.level == .info }
    }
    
    var warnLogs: [LogEntry] {
        logs.filter { $0.level == .warn }
    }
    
    var errorLogs: [LogEntry] {
        logs.filter { $0.level == .error }
    }
    
    func hasLog(level: LogLevel, containing text: String) -> Bool {
        logs.contains { $0.level == level && $0.message.contains(text) }
    }
}
