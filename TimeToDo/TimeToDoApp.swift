import SwiftUI

extension Notification.Name {
    static let tasksChangedFromWidget = Notification.Name("tasksChangedFromWidget")
}

@main
struct TimeToDoApp: App {
    @StateObject private var taskStore = TaskStore()
    @StateObject private var authManager = AuthorizationManager()
    @StateObject private var selectionManager = AppSelectionManager()
    @StateObject private var blockingManager = BlockingManager()
    @AppStorage("blockingDisabled") private var blockingDisabled = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            TaskListView()
                .environmentObject(taskStore)
                .environmentObject(authManager)
                .environmentObject(selectionManager)
                .environmentObject(blockingManager)
                .task {
                    authManager.refreshStatus()
                    evaluateBlocking()
                }
                .onChange(of: authManager.isAuthorized) { _, _ in evaluateBlocking() }
                .onChange(of: taskStore.tasks) { _, _ in
                    Task { @MainActor in evaluateBlocking() }
                }
                .onChange(of: selectionManager.selection) { _, _ in evaluateBlocking() }
                .onChange(of: blockingDisabled) { _, _ in evaluateBlocking() }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        taskStore.reloadFromDisk()
                        evaluateBlocking()
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .tasksChangedFromWidget)) { _ in
                    taskStore.reloadFromDisk()
                    evaluateBlocking()
                }
                .onAppear { registerForWidgetChanges() }
        }
    }

    private func registerForWidgetChanges() {
        let name = "com.ravinlabsdev.TimeToDo.tasksChanged" as CFString
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            nil,
            { _, _, _, _, _ in
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .tasksChangedFromWidget, object: nil)
                }
            },
            name, nil, .deliverImmediately
        )
    }

    private func evaluateBlocking() {
        blockingManager.evaluate(
            authorized: authManager.isAuthorized,
            hasSelection: selectionManager.hasSelection,
            selection: selectionManager.selection,
            todayAllCompleted: taskStore.todayAllCompleted || blockingDisabled
        )
    }
}
