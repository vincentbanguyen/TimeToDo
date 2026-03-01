import SwiftUI

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
                    if phase == .active { evaluateBlocking() }
                }
        }
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
