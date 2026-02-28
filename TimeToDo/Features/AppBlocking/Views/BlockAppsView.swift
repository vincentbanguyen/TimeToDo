import SwiftUI
import FamilyControls

struct BlockAppsView: View {
    @EnvironmentObject var authManager: AuthorizationManager
    @EnvironmentObject var selectionManager: AppSelectionManager
    @EnvironmentObject var blockingManager: BlockingManager
    @EnvironmentObject var store: TaskStore

    private var isActivelyBlocking: Bool {
        authManager.isAuthorized && selectionManager.hasSelection && !store.todayAllCompleted
    }

    var body: some View {
        NavigationStack {
            List {
                // Authorization Section (only shown when not yet authorized)
                if !authManager.isAuthorized {
                    Section {
                        HStack {
                            Label("Not Authorized", systemImage: "shield.slash")
                                .foregroundColor(.colorTextSecondary)

                            Spacer()

                            Button("Request") {
                                Task { await authManager.requestAuthorization() }
                            }
                            .fontWeight(.semibold)
                        }
                    } header: {
                        Text("Screen Time Access")
                    } footer: {
                        Text("TimeToDo needs Screen Time access to block apps until you complete your tasks.")
                    }
                }

                // Status indicator
                if authManager.isAuthorized {
                    Section {
                        HStack {
                            Label(
                                isActivelyBlocking ? "Blocking Active" : "Not Blocking",
                                systemImage: isActivelyBlocking ? "shield.checkered" : "shield.slash"
                            )
                            .foregroundColor(isActivelyBlocking ? .colorSuccess : .colorTextSecondary)

                            Spacer()

                            if selectionManager.hasSelection {
                                Text("\(selectionManager.selectedCount) selected")
                                    .font(.fontCaption)
                                    .foregroundColor(.colorTextSecondary)
                            }
                        }
                    } header: {
                        Text("Status")
                    }
                }

                // App Picker Section
                if authManager.isAuthorized {
                    Section {
                        FamilyActivityPicker(selection: $selectionManager.selection)
                            .frame(minHeight: 600)
                    } header: {
                        Text("Apps to Block")
                    }
                }
            }
            .navigationTitle("Block Apps")
            .onAppear {
                authManager.refreshStatus()
            }
        }
    }
}
