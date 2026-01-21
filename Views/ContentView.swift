import SwiftUI
import SwiftData

/// Root view - shows launch screen then main app
struct ContentView: View {
    private var settings = UserSettings.shared
    
    var body: some View {
        LaunchScreen()
            .preferredColorScheme(settings.appearanceMode.colorScheme)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Transaction.self, Category.self], inMemory: true)
}
