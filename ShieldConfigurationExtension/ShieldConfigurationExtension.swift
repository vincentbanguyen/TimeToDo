import ManagedSettingsUI
import ManagedSettings
import UIKit
import Foundation

nonisolated class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        makeConfiguration(blockedThing: "app")
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        makeConfiguration(blockedThing: "app")
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        makeConfiguration(blockedThing: "site")
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        makeConfiguration(blockedThing: "site")
    }

    private func makeConfiguration(blockedThing: String) -> ShieldConfiguration {
        let remaining = remainingTasks()
        let subtitle: String

        if remaining.isEmpty {
            subtitle = "Open TimeToDo to unlock this \(blockedThing)."
        } else {
            let names = remaining.map { "• \($0.title)" }.joined(separator: "\n")
            subtitle = "Complete to unlock:\n\(names)"
        }

        return ShieldConfiguration(
            backgroundBlurStyle: .systemThickMaterial,
            icon: UIImage(systemName: "checkmark.circle"),
            title: ShieldConfiguration.Label(text: "App Blocked", color: .label),
            subtitle: ShieldConfiguration.Label(text: subtitle, color: .secondaryLabel),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Close", color: .white),
            primaryButtonBackgroundColor: .systemBlue
        )
    }

    private func remainingTasks() -> [TaskData] {
        let appGroupID = "group.com.ravinlabsdev.TimeToDo"
        let fileName = "tasks.json"

        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            return []
        }

        let fileURL = container.appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: fileURL),
              let tasks = try? JSONDecoder().decode([TaskData].self, from: data) else {
            return []
        }

        // Only show today's incomplete tasks (dueDate <= end of today)
        let endOfToday = Calendar.current.startOfDay(for: .now).addingTimeInterval(86400)
        return tasks.filter { !$0.isCompleted && $0.dueDate < endOfToday }
    }
}

private struct TaskData: Decodable {
    let title: String
    let isCompleted: Bool
    let dueDate: Date
}
