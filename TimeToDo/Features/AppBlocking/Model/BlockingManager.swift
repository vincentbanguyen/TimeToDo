import ManagedSettings
import FamilyControls
import Combine

@MainActor
class BlockingManager: ObservableObject {
    private let store = ManagedSettingsStore()
    @Published var isBlocking = false

    func blockApps(selection: FamilyActivitySelection) {
        let apps = selection.applicationTokens
        let categories = selection.categoryTokens
        let webDomains = selection.webDomainTokens

        guard !apps.isEmpty || !categories.isEmpty || !webDomains.isEmpty else { return }

        store.shield.applications = apps.isEmpty ? nil : apps
        store.shield.applicationCategories = categories.isEmpty ? nil : .specific(categories)
        store.shield.webDomains = webDomains.isEmpty ? nil : webDomains

        isBlocking = true
    }

    func unblockApps() {
        store.clearAllSettings()
        isBlocking = false
    }

    func updateBlocking(allTasksCompleted: Bool, selection: FamilyActivitySelection) {
        if allTasksCompleted {
            unblockApps()
        } else {
            blockApps(selection: selection)
        }
    }
}
