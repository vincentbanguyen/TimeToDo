import SwiftUI
import DeviceActivity

extension DeviceActivity.DeviceActivityReport.Context {
    static let totalActivity = Self("Total Activity")
}

struct ScreenTimeView: View {
    @EnvironmentObject var authManager: AuthorizationManager
    @State private var selectedFilter = ScreenTimeFilter.today

    private var dateFilter: DeviceActivityFilter {
        let calendar = Calendar.current
        let now = Date()

        switch selectedFilter {
        case .today:
            let startOfDay = calendar.startOfDay(for: now)
            return DeviceActivityFilter(
                segment: .daily(during: DateInterval(start: startOfDay, end: now))
            )
        case .thisWeek:
            let startOfWeek = calendar.date(
                from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
            ) ?? now
            return DeviceActivityFilter(
                segment: .weekly(during: DateInterval(start: startOfWeek, end: now))
            )
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                if !authManager.isAuthorized {
                    ContentUnavailableView {
                        Label("Screen Time Access Required", systemImage: "hourglass")
                    } description: {
                        Text("Authorize Screen Time access in the Block Apps tab to view your usage data.")
                    }
                } else {
                    Picker("Period", selection: $selectedFilter) {
                        ForEach(ScreenTimeFilter.allCases) { filter in
                            Text(filter.title).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    DeviceActivity.DeviceActivityReport(.totalActivity, filter: dateFilter)
                }
            }
            .navigationTitle("Screen Time")
        }
    }
}

enum ScreenTimeFilter: String, CaseIterable, Identifiable {
    case today = "Today"
    case thisWeek = "This Week"

    var id: String { rawValue }
    var title: String { rawValue }
}
