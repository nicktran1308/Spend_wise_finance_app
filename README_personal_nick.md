# SpendWise - Personal Finance Tracker

A SwiftUI + SwiftData iOS app for tracking income and expenses.

## 10-Day Development Plan

| Day | Focus | Status |
|-----|-------|--------|
| 1 | Project setup + Data models | ✅ Complete |
| 2 | Tab navigation + Home screen | ✅ Complete |
| 3 | Transaction list | ✅ Complete |
| 4 | Add transaction | ✅ Complete |
| 5 | Budget screen | ✅ Complete |
| 6 | Statistics screen | ✅ Complete |
| 7 | Settings + User preferences | ✅ Complete |
| 8 | Notifications | ✅ Complete |
| 9 | Widgets | ⚠️ App Group Issue |
| 10 | Polish + Testing | ✅ Complete |

---

## Project Structure

```
spendwise_nick/
├── App/
│   └── spendwise_nickApp.swift      # App entry point, SwiftData container
├── Models/
│   ├── Transaction.swift            # Income/expense data model
│   ├── Category.swift               # Budget category model
│   ├── ChartDataModels.swift        # Data structures for charts
│   ├── UserSettings.swift           # @Observable settings with UserDefaults
│   └── SharedModelContainer.swift   # Shared SwiftData container
├── Views/
│   ├── ContentView.swift            # Root view with appearance setting
│   ├── MainTabView.swift            # Tab navigation
│   ├── LaunchScreen.swift           # Animated splash screen
│   ├── Home/
│   │   ├── HomeView.swift           # Balance card, recent transactions
│   │   └── TransactionListView.swift # Full list with filtering
│   ├── Budget/
│   │   ├── BudgetView.swift         # Category budgets with month selector
│   │   └── EditBudgetSheet.swift    # Budget editing modal
│   ├── AddTransaction/
│   │   └── AddTransactionView.swift # Transaction form with category grid
│   ├── Stats/
│   │   └── StatsView.swift          # Swift Charts statistics
│   └── Settings/
│       ├── SettingsView.swift       # Main settings screen
│       ├── ProfileEditSheet.swift   # Name/email editing
│       ├── CurrencyPickerSheet.swift # Currency selection
│       ├── AppearancePickerSheet.swift # Dark/light mode
│       ├── ExportDataSheet.swift    # CSV export with share
│       └── NotificationSettingsView.swift # Notification preferences
├── Components/
│   ├── TransactionRow.swift         # Reusable transaction row
│   ├── ProgressBar.swift            # Animated progress bar
│   ├── BudgetCategoryCard.swift     # Budget category display card
│   ├── StatCard.swift               # Compact stat display card
│   ├── EmptyStateView.swift         # Reusable empty state
│   ├── LoadingView.swift            # Reusable loading indicator
│   └── CategoryPickerSheet.swift    # Modal category picker (optional)
├── Services/
│   ├── NotificationManager.swift    # Notification permissions & scheduling
│   └── BudgetNotificationService.swift # Budget checking & alerts
├── ViewModels/                      # (future)
└── Utilities/
    ├── Color+Extensions.swift       # Hex color support
    ├── Date+Extensions.swift        # Date helpers
    ├── Double+Extensions.swift      # Currency formatting
    └── HapticManager.swift          # Centralized haptic feedback

SpendWiseWidget/                     # Widget Extension (requires App Group fix)
├── SpendWiseWidget.swift            # Widget views & timeline provider
└── SpendWiseWidgetBundle.swift      # Widget bundle entry point
```

---

## Known Issues & Fixes

### Issue 1: `Type 'ShapeStyle' has no member 'incomeGreen'`

**Cause:** Custom colors are extensions on `Color`, not `ShapeStyle`.

**Fix:** Use `Color.incomeGreen` instead of `.incomeGreen`

```swift
// ❌ Wrong
.foregroundStyle(.incomeGreen)

// ✅ Correct
.foregroundStyle(Color.incomeGreen)
```

**Files to check:**
- `TransactionRow.swift`
- `HomeView.swift`
- `BudgetView.swift`

---

### Issue 2: `'main' attribute can only apply to one type in a module`

**Cause:** Multiple files with `@main` are assigned to the same target.

**Fix:** Check Target Membership for these files:

| File | Main App | Widget |
|------|----------|--------|
| `spendwise_nickApp.swift` | ☑ | ☐ |
| `SpendWiseWidgetBundle.swift` | ☐ | ☑ |
| `SpendWiseWidget.swift` | ☐ | ☑ |

**How to fix:**
1. Select the file in Project Navigator
2. Open File Inspector (⌥ + ⌘ + 1)
3. Under **Target Membership**, check/uncheck appropriate targets

---

### Issue 3: `Value of type 'some Scene' has no member 'onAppear'`

**Cause:** `.onAppear` is a View modifier, not a Scene modifier.

**Fix:** Use `init()` instead of `.onAppear` in the App struct:

```swift
// ❌ Wrong
var body: some Scene {
    WindowGroup {
        ContentView()
    }
    .onAppear { /* code */ }  // Error!
}

// ✅ Correct
init() {
    // Setup code here
}

var body: some Scene {
    WindowGroup {
        ContentView()
    }
}
```

---

### Issue 4: Widget Crash / App Group Error

**Cause:** App Group not configured correctly, causing `containerURL` to return `nil`.

**Error message:**
```
Failed to show Widget 'co.nicktran.spendwise-nick.SpendWiseWidget'
Connection invalidated
```

**Temporary Fix:** Use local container (widgets won't work):

```swift
// In SharedModelContainer.swift
static var sharedModelContainer: ModelContainer = {
    let schema = Schema([Transaction.self, Category.self])
    
    // Use default container (not shared with widget)
    do {
        return try ModelContainer(for: schema)
    } catch {
        fatalError("Failed to create model container: \(error)")
    }
}()
```

**Permanent Fix:** Configure App Groups properly:

1. Select **spendwise_nick** target → **Signing & Capabilities**
2. Add **App Groups** capability
3. Create group: `group.co.nicktran.spendwise-nick`
4. Select **SpendWiseWidgetExtension** target
5. Add same **App Groups** capability
6. Check the same group
7. Clean build (⇧ + ⌘ + K) and run

---

### Issue 5: Widget Not Showing Data

**Cause:** Files not shared with widget target.

**Fix:** Share these files with both targets:

| File | Main App | Widget |
|------|----------|--------|
| `SharedModelContainer.swift` | ☑ | ☑ |
| `Transaction.swift` | ☑ | ☑ |
| `Category.swift` | ☑ | ☑ |
| `Color+Extensions.swift` | ☑ | ☑ |
| `Double+Extensions.swift` | ☑ | ☑ |
| `Date+Extensions.swift` | ☑ | ☑ |

---

### Issue 6: Preview Not Working

**Fix:**
1. Press ⌥ + ⌘ + Enter to show Canvas
2. Click **Resume** if paused
3. Build first (⌘ + B) to check for errors
4. Ensure `#Preview` block exists in file
5. Add `.modelContainer(for:..., inMemory: true)` for SwiftData views

---

## Day-by-Day Summary

### Day 1: Project Setup + Data Models

**Files:**
- `Transaction.swift` — Core data model with `@Model` macro
- `Category.swift` — Categories with budgets, default seeding
- `spendwise_nickApp.swift` — SwiftData container setup
- `Color+Extensions.swift` — Hex ↔ Color conversion
- `Date+Extensions.swift` — Date helpers
- `Double+Extensions.swift` — Currency formatting

**Key Concepts:**
- `@Model` — SwiftData persistence macro
- `@Relationship` — Category ↔ Transaction link
- Default seeding on first launch

---

### Day 2: Tab Navigation + Home Screen

**Files:**
- `MainTabView.swift` — 5-tab navigation
- `HomeView.swift` — Balance card, recent transactions
- `TransactionRow.swift` — Reusable list row
- Placeholder views for other tabs

**Key Concepts:**
- `TabView` with selection binding
- `@Query` for reactive data fetching
- Computed properties for aggregation

---

### Day 3: Transaction List with Filtering

**Features:**
- Date grouping (Today, Yesterday, etc.)
- Swipe-to-delete
- Filter by type (All/Income/Expense)
- Search by title
- Empty states

**Key Concepts:**
- `Dictionary(grouping:)` for date grouping
- `.searchable()` modifier
- `.swipeActions()` for delete
- `ContentUnavailableView` (iOS 17)

---

### Day 4: Add Transaction Screen

**Features:**
- Large amount display
- Category grid picker
- Type toggle (Expense/Income)
- Haptic feedback
- Success overlay animation

**Key Concepts:**
- `LazyVGrid` for category layout
- `UIImpactFeedbackGenerator` for haptics
- `.overlay` with animation

---

### Day 5: Budget Screen

**Features:**
- Monthly overview card
- Category progress bars
- Edit budgets via sheet
- Month navigation
- Visual warnings (90%, 100%)

**Key Concepts:**
- `.sheet(item:)` with binding
- `.presentationDetents()` for sheet height
- `Calendar.current.date(byAdding:)` for month math

---

### Day 6: Statistics with Swift Charts

**Features:**
- Weekly/Monthly spending bar chart
- Category donut chart
- Summary stat cards
- Time period selector

**Key Concepts:**
- `import Charts`
- `BarMark` for bar charts
- `SectorMark` for donut charts
- Custom axis labels

---

### Day 7: Settings + Preferences

**Features:**
- User profile editing
- Currency selection (10 options)
- Appearance mode (System/Light/Dark)
- Export to CSV
- Reset all data

**Key Concepts:**
- `@Observable` class for settings
- `UserDefaults` persistence
- `UIActivityViewController` for sharing
- `.preferredColorScheme()` modifier

---

### Day 8: Notifications

**Features:**
- Budget alerts at 80%, 90%, 100%
- Daily expense reminder
- Permission handling
- Threshold tracking (no duplicates)

**Key Concepts:**
- `UNUserNotificationCenter`
- `UNTimeIntervalNotificationTrigger`
- `UNCalendarNotificationTrigger`
- `.interruptionLevel` for priority

---

### Day 9: Widgets

**Features:**
- Small widget (balance)
- Medium widget (balance + transactions)
- Large widget (balance + chart + transactions)
- Auto-refresh every 15 minutes

**Key Concepts:**
- Widget Extension target
- App Groups for shared data
- `TimelineProvider` protocol
- `WidgetCenter.shared.reloadAllTimelines()`

**⚠️ Requires App Group configuration to work**

---

### Day 10: Polish + Testing

**Features:**
- Animated launch screen
- Reusable empty state component
- Loading view component
- Centralized haptic manager
- Accessibility labels

**Key Concepts:**
- Launch animations with `withAnimation`
- `.accessibilityLabel()` for VoiceOver
- `HapticManager` enum for feedback

---

## Requirements

- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

---

## How to Run

1. Open `spendwise_nick.xcodeproj` in Xcode
2. Select scheme: **spendwise_nick** (not widget)
3. Select simulator: iPhone 15 Pro
4. Press ⌘ + R to build and run

---

## Testing Checklist

| Feature | Test | Status |
|---------|------|--------|
| Launch | App shows splash then home | ☐ |
| Add transaction | Form validates, haptic, success | ☐ |
| Delete transaction | Swipe left works | ☐ |
| Filter transactions | All/Income/Expense toggle | ☐ |
| Search transactions | Filter by title | ☐ |
| Budget progress | Bars update correctly | ☐ |
| Edit budget | Tap category, change amount | ☐ |
| Statistics charts | Bar and donut display | ☐ |
| Period selector | Week/Month/Year toggle | ☐ |
| Settings profile | Edit name/email | ☐ |
| Currency setting | Change currency | ☐ |
| Appearance | Light/Dark/System modes | ☐ |
| Export CSV | Share sheet opens | ☐ |
| Reset data | Clears all transactions | ☐ |
| Notifications | Budget alerts fire | ☐ |
| Widget | Shows on home screen | ☐ (requires App Group) |

---

## Troubleshooting

### App crashes on launch
- Check `SharedModelContainer.swift` is using local container (not shared)
- Clean build: ⇧ + ⌘ + K
- Delete app from simulator and reinstall

### Build errors about targets
- Check Target Membership for all files
- Ensure `@main` files belong to only ONE target each

### Preview not loading
- Build first (⌘ + B)
- Check for compile errors
- Add `.modelContainer(for:..., inMemory: true)` to preview

### Widget not working
- App Groups must be configured in both targets
- Use same Team for signing both targets
- Share required files with widget target

---

## Future Improvements

- [ ] iCloud sync
- [ ] Recurring transactions
- [ ] Multiple accounts
- [ ] Budget rollover
- [ ] Receipt photo attachment
- [ ] Apple Watch app
- [ ] Siri shortcuts
