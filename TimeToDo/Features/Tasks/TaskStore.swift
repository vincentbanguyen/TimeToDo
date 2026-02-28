import SwiftUI
import Combine

@MainActor
class TaskStore: ObservableObject {
    @Published var tasks: [TaskItem] = []

    private static let fileName = "tasks.json"

    init() {
        load()
    }

    // MARK: - CRUD

    func addTask(title: String, dueDate: Date = .now) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        tasks.append(TaskItem(title: trimmed, dueDate: dueDate))
        save()
    }

    func toggleTask(_ task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }

        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()

        tasks[index].isCompleted.toggle()
        tasks[index].lastModified = Date()
        save()
    }

    func deleteTask(_ task: TaskItem) {
        tasks.removeAll { $0.id == task.id }
        save()
    }

    func deleteTasks(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        save()
    }

    func moveTasks(from source: IndexSet, to destination: Int) {
        tasks.move(fromOffsets: source, toOffset: destination)
        save()
    }

    func updateTitle(_ task: TaskItem, to newTitle: String) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].title = newTitle
        tasks[index].lastModified = Date()
        save()
    }

    // MARK: - Date-Based Computed

    /// Today's tasks: dueDate <= today (includes rolled-over past tasks)
    var todayTasks: [TaskItem] {
        let endOfToday = Calendar.current.startOfDay(for: .now).addingTimeInterval(86400)
        return tasks.filter { $0.dueDate < endOfToday }
    }

    /// Today's incomplete tasks only
    var todayIncompleteTasks: [TaskItem] {
        todayTasks.filter { !$0.isCompleted }
    }

    /// Whether all of today's tasks are completed (used for blocking logic)
    var todayAllCompleted: Bool {
        let today = todayTasks
        return today.isEmpty || today.allSatisfy(\.isCompleted)
    }

    /// Tasks grouped by date section for display.
    /// "Today" includes all tasks with dueDate <= today (rollover).
    /// Future dates are grouped by their individual day.
    var tasksBySection: [(title: String, tasks: [TaskItem])] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfToday)!

        var sections: [(title: String, tasks: [TaskItem])] = []

        // Today: dueDate <= end of today (includes rolled-over past tasks)
        let today = tasks.filter { $0.dueDate < startOfTomorrow }
        if !today.isEmpty {
            sections.append(("Today's Tasks", today))
        }

        // Future tasks grouped by date
        let futureTasks = tasks.filter { $0.dueDate >= startOfTomorrow }
        let grouped = Dictionary(grouping: futureTasks) { task in
            calendar.startOfDay(for: task.dueDate)
        }

        for date in grouped.keys.sorted() {
            guard let dayTasks = grouped[date] else { continue }
            let title: String
            if calendar.isDate(date, inSameDayAs: startOfTomorrow) {
                title = "Tomorrow"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE, MMM d"
                title = formatter.string(from: date)
            }
            sections.append((title, dayTasks))
        }

        return sections
    }

    // MARK: - Legacy Computed (kept for compatibility)

    var incompleteTasks: [TaskItem] {
        tasks.filter { !$0.isCompleted }
    }

    var allCompleted: Bool {
        todayAllCompleted
    }

    // MARK: - Persistence

    private static let appGroupID = "group.com.ravinlabsdev.TimeToDo"

    private static var fileURL: URL {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
        let directory = container ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent(fileName)
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(tasks)
            try data.write(to: Self.fileURL, options: .atomic)
        } catch {
            print("Failed to save tasks: \(error)")
        }
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: Self.fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: Self.fileURL)
            tasks = try JSONDecoder().decode([TaskItem].self, from: data)
        } catch {
            print("Failed to load tasks: \(error)")
        }
    }
}
