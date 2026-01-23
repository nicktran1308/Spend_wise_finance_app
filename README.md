# SpendWise - Personal Finance Tracker

A SwiftUI + SwiftData iOS app for tracking income and expenses.

## Project Structure

```
spendwise_nick/
├── .gitignore                        # Ignore rules for local/secret files
├── README.md                         # Public repo summary (short)
├── README_personal_nick.md           # Personal notes (this file)
├── spendwise_nick.xcodeproj/         # Xcode project configuration
│   └── project.pbxproj               # Build settings, targets, file refs
├── spendwise_nick.entitlements       # App entitlements (e.g., App Groups)
├── SpendWiseWidgetExtension.entitlements # Widget entitlements
├── App/
│   └── spendwise_nickApp.swift        # App entry point + SwiftData setup
├── Models/
│   ├── Transaction.swift             # Income/expense data model
│   ├── Category.swift                # Budget category model
│   ├── ChartDataModels.swift         # Chart-friendly data structures
│   ├── UserSettings.swift            # @Observable settings + UserDefaults
│   └── SharedModelContainer.swift    # SwiftData container selection
├── Views/
│   ├── ContentView.swift             # Root view + appearance handling
│   ├── MainTabView.swift             # Tab navigation
│   ├── LaunchScreen.swift            # Animated splash screen
│   ├── Home/
│   │   ├── HomeView.swift            # Balance card + recent transactions
│   │   └── TransactionListView.swift # Full list with search/filter
│   ├── Budget/
│   │   ├── BudgetView.swift          # Budgets overview by month
│   │   └── EditBudgetSheet.swift     # Edit budget modal
│   ├── AddTransaction/
│   │   └── AddTransactionView.swift  # Add transaction form + category grid
│   ├── Stats/
│   │   └── StatsView.swift           # Swift Charts statistics
│   └── Settings/
│       ├── SettingsView.swift        # Settings hub
│       ├── ProfileEditSheet.swift    # Name/email editing
│       ├── CurrencyPickerSheet.swift # Currency selection
│       ├── ApperancePickerSheet.swift # Light/Dark/System mode
│       ├── ExportDataSheet.swift     # CSV export + share sheet
│       └── NotificationSettingsView.swift # Notification toggles
├── Components/
│   ├── TransactionRow.swift          # Reusable transaction row
│   ├── ProgressBar.swift             # Animated progress bar
│   ├── BudgetCategoryCard.swift      # Budget category card
│   ├── StatCard.swift                # Compact stat card
│   ├── EmptyStateView.swift          # Reusable empty state
│   ├── LoadingView.swift             # Reusable loading indicator
│   └── CategoryPickerSheet.swift     # Category picker sheet
├── Service/
│   ├── NotificationManager.swift     # Notification permissions + scheduling
│   └── BudgetNotificationService.swift # Budget checks + alerts
└── Utilities/
    ├── Color+Extensions.swift        # Hex color support
    ├── Date+Extensions.swift         # Date helpers
    ├── Double+Extensions.swift       # Currency formatting
    └── HapticManager.swift           # Centralized haptic feedback

SpendWiseWidget/                      # Widget extension target
├── AppIntent.swift                   # Widget configuration intent
├── SpendWiseWidget.swift             # Widget views + timeline provider
├── SpendWiseWidgetBundle.swift       # Widget bundle entry point
├── SpendWiseWidgetControl.swift      # Widget control/interaction
├── Info.plist                        # Widget extension plist
└── Assets.xcassets/                  # Widget-specific assets
```

## Improvement Ideas 

- Automated import (Plaid or CSV) to reduce manual entry
- Recurring transactions + subscription detection
- Budget rollovers / envelope budgeting
- Cash‑flow forecasting (next 30/60/90 days)
- Multi‑account support + net‑worth view
- Smart categorization (rules + suggestions)
- Goals / saving buckets with progress tracking
- Receipt capture + OCR for fast entry
- Privacy + sync: local‑first, optional iCloud, Face ID lock
- Expanded surfaces: widgets + Apple Watch quick add
