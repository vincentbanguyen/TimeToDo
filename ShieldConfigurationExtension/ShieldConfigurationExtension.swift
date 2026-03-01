import ManagedSettingsUI
import ManagedSettings
import UIKit

nonisolated class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    private static let appGroupID = "group.com.ravinlabsdev.TimeToDo"

    override func configuration(shielding application: Application) -> ShieldConfiguration { shieldConfig }
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration { shieldConfig }
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration { shieldConfig }
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration { shieldConfig }

    private var shieldConfig: ShieldConfiguration {
        let tasks = remainingTasks()
        let subtitle = "Complete today's tasks to unlock:\n" + tasks.map { "• \($0.title)" }.joined(separator: "\n")

        return ShieldConfiguration(
            backgroundBlurStyle: .systemThickMaterial,
            icon: UIImage(systemName: "checkmark.circle"),
            title: .init(text: "App Blocked", color: .label),
            subtitle: .init(text: subtitle, color: .secondaryLabel),
            primaryButtonLabel: .init(text: "Close", color: .white),
            primaryButtonBackgroundColor: .systemBlue
        )
    }

    private func remainingTasks() -> [TaskData] {
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Self.appGroupID),
              let data = try? Data(contentsOf: container.appendingPathComponent("tasks.json")),
              let tasks = try? JSONDecoder().decode([TaskData].self, from: data) else {
            return []
        }
        let startOfTomorrow = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: .now)!)
        return tasks.filter { !$0.isCompleted && $0.dueDate < startOfTomorrow }
    }
}

private struct TaskData: Decodable {
    let title: String
    let isCompleted: Bool
    let dueDate: Date
}
