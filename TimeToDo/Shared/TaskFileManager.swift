import Foundation

enum TaskFileManager {
    private static var fileURL: URL {
        let container = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: AppConstants.appGroupID
        )
        let directory = container ?? FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask
        )[0]
        return directory.appendingPathComponent(AppConstants.tasksFileName)
    }

    static func loadTasks() -> [TaskItem] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([TaskItem].self, from: data)
        } catch {
            return []
        }
    }

    static func saveTasks(_ tasks: [TaskItem]) {
        do {
            let data = try JSONEncoder().encode(tasks)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("TaskFileManager: Failed to save tasks: \(error)")
        }
    }

    static func todayTasks() -> [TaskItem] {
        let all = loadTasks()
        let startOfTomorrow = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: .now)!
        )
        return all.filter { $0.dueDate < startOfTomorrow }
    }
}
