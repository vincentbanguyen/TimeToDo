import FamilyControls
import Combine

@MainActor
class AuthorizationManager: ObservableObject {
    @Published var isAuthorized = false

    init() {
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
    }

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
        } catch {
            print("FamilyControls authorization failed: \(error)")
            isAuthorized = false
        }
    }

    func refreshStatus() {
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
    }
}
