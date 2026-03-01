import Combine
import FamilyControls

@MainActor
class AuthorizationManager: ObservableObject {
    @Published var isAuthorized = false

    init() { refreshStatus() }

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        } catch {
            print("FamilyControls authorization failed: \(error)")
        }
        refreshStatus()
    }

    func refreshStatus() {
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
    }
}
