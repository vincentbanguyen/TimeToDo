//
//  TimeToDoApp.swift
//  TimeToDo
//
//  Created by Vincent Nguyen on 2/28/26.
//

import SwiftUI
import Combine
import FamilyControls

@main
struct TimeToDoApp: App {
    @StateObject private var taskStore = TaskStore()
    @StateObject private var authManager = AuthorizationManager()
    @StateObject private var selectionManager = AppSelectionManager()
    @StateObject private var blockingManager = BlockingManager()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(taskStore)
                .environmentObject(authManager)
                .environmentObject(selectionManager)
                .environmentObject(blockingManager)
                .onReceive(taskStore.$tasks) { _ in
                    guard authManager.isAuthorized, selectionManager.hasSelection else { return }
                    blockingManager.updateBlocking(
                        allTasksCompleted: taskStore.todayAllCompleted,
                        selection: selectionManager.selection
                    )
                }
                .onReceive(selectionManager.$selection) { selection in
                    guard authManager.isAuthorized else { return }
                    let hasSelection = !selection.applicationTokens.isEmpty ||
                                       !selection.categoryTokens.isEmpty ||
                                       !selection.webDomainTokens.isEmpty
                    if hasSelection {
                        blockingManager.updateBlocking(
                            allTasksCompleted: taskStore.todayAllCompleted,
                            selection: selection
                        )
                    } else {
                        blockingManager.unblockApps()
                    }
                }
                .onChange(of: scenePhase) { _, newPhase in
                    guard newPhase == .active, authManager.isAuthorized else { return }
                    if selectionManager.hasSelection {
                        blockingManager.updateBlocking(
                            allTasksCompleted: taskStore.todayAllCompleted,
                            selection: selectionManager.selection
                        )
                    } else {
                        blockingManager.unblockApps()
                    }
                }
        }
    }
}
