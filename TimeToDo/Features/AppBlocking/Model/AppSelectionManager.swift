import Foundation
import FamilyControls
import Combine

@MainActor
class AppSelectionManager: ObservableObject {
    static let appGroupID = "group.com.ravinlabsdev.TimeToDo"
    private static let selectionKey = "selectedApps"

    @Published var selection = FamilyActivitySelection() {
        didSet { save() }
    }

    var hasSelection: Bool {
        !selection.applicationTokens.isEmpty ||
        !selection.categoryTokens.isEmpty ||
        !selection.webDomainTokens.isEmpty
    }

    var selectedCount: Int {
        selection.applicationTokens.count +
        selection.categoryTokens.count +
        selection.webDomainTokens.count
    }

    init() {
        load()
    }

    // MARK: - Persistence (App Group UserDefaults)

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: Self.appGroupID)
    }

    private func save() {
        guard let defaults = sharedDefaults else { return }
        do {
            let data = try JSONEncoder().encode(selection)
            defaults.set(data, forKey: Self.selectionKey)
        } catch {
            print("Failed to save app selection: \(error)")
        }
    }

    private func load() {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: Self.selectionKey) else { return }
        do {
            selection = try JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        } catch {
            print("Failed to load app selection: \(error)")
        }
    }
}
