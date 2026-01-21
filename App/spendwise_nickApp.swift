import SwiftUI
import SwiftData

/// Main app entry point
@main
struct spendwise_nickApp: App {
    
    // MARK: - Initialization
    
    init() {
        // Seed default categories if needed
        seedDefaultCategoriesIfNeeded()
        
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
    
    // MARK: - Private Methods
    
    /// Seeds default categories if none exist
    private func seedDefaultCategoriesIfNeeded() {
        let context = SharedModelContainer.sharedModelContainer.mainContext
        
        // Check if categories already exist
        let descriptor = FetchDescriptor<Category>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        
        guard existingCount == 0 else { return }
        
        // Insert default categories
        for category in Category.allDefaults {
            context.insert(category)
        }
        
        try? context.save()
    }
}
