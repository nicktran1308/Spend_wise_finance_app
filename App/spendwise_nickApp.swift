import SwiftUI
import SwiftData

/// Main app entry point
@main
struct spendwise_nickApp: App {
    
    // MARK: - Initialization
    
    init() {
        // Request notification permission
        Task {
            await NotificationManager.shared.requestAuthorization()
        }
    }
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(SharedModelContainer.sharedModelContainer)
    }
    
}
