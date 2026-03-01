import SwiftUI
import FamilyControls

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthorizationManager
    @AppStorage("hideCompletedTasks") private var hideCompletedTasks = true
    @AppStorage("blockingDisabled") private var blockingDisabled = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Hide Completed Tasks", isOn: $hideCompletedTasks)
                } header: {
                    Text("Display")
                }

                Section {
                    Toggle("Disable App Blocking", isOn: $blockingDisabled)
                } header: {
                    Text("Blocking")
                } footer: {
                    Text("When enabled, apps will not be blocked even if you have incomplete tasks.")
                }

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
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                authManager.refreshStatus()
            }
        }
    }
}
