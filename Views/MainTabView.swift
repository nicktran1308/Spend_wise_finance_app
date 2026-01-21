import SwiftUI

/// Main tab navigation for the app
struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(Tab.home)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            BudgetView()
                .tag(Tab.budget)
                .tabItem {
                    Label("Budget", systemImage: "chart.pie.fill")
                }
            
            AddTransactionView()
                .tag(Tab.add)
                .tabItem {
                    Label("Add", systemImage: "plus.circle.fill")
                }
            
            StatsView()
                .tag(Tab.stats)
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
            
            SettingsView()
                .tag(Tab.settings)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(.accentBlue)
    }
}

// MARK: - Tab Enum

extension MainTabView {
    enum Tab: Int, CaseIterable {
        case home
        case budget
        case add
        case stats
        case settings
    }
}

#Preview {
    MainTabView()
        .preferredColorScheme(.dark)
        .modelContainer(for: [Transaction.self, Category.self], inMemory: true)
}
