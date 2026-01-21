//
//  SharedModelContainer.swift
//  spendwise_nick
//
//  Created by Nick on 1/13/26.
//

import Foundation
import SwiftData

/// Model container - using standard location (not shared)
/// Change to shared container later when App Groups is configured
struct SharedModelContainer {
    
    /// App group identifier for shared data
    static let appGroupIdentifier = "group.co.nicktran.spendwise-nick"
    
    /// Shared SwiftData model container
    static var sharedModelContainer: ModelContainer = {
        let schema = Schema([Transaction.self, Category.self])
        
        // Use default container (not shared with widget)
        // Widget won't work until App Groups is properly configured
        do {
            return try ModelContainer(for: schema)
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }()
}
