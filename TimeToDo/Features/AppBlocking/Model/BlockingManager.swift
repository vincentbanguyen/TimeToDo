import Combine
import ManagedSettings
import FamilyControls

@MainActor
class BlockingManager: ObservableObject {
    private let managedStore = ManagedSettingsStore()
    @Published var isBlocking = false

    func evaluate(authorized: Bool, hasSelection: Bool, selection: FamilyActivitySelection, todayAllCompleted: Bool) {
        let shouldBlock = authorized && hasSelection && !todayAllCompleted

        if shouldBlock {
            managedStore.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
            managedStore.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens)
            managedStore.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
            isBlocking = true
        } else {
            managedStore.clearAllSettings()
            isBlocking = false
        }
    }
}
