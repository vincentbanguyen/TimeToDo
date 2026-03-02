import SwiftUI
import Combine
import WidgetKit

@MainActor
class TaskStore: ObservableObject {
    @Published var tasks: [TaskItem] = []

    private static let sectionDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f
    }()

    init() { load() }

    // MARK: - CRUD

    func addTask(title: String, dueDate: Date = .now) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        tasks.append(TaskItem(title: trimmed, dueDate: dueDate))
        save()
    }

    func toggleTask(_ task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        tasks[index].isCompleted.toggle()
        save()
    }

    func deleteTask(_ task: TaskItem) {
        tasks.removeAll { $0.id == task.id }
        save()
    }

    func updateTitle(_ task: TaskItem, to newTitle: String) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].title = newTitle
        save()
    }

    // MARK: - Blocking Logic

    /// Whether all of today's tasks are completed (used for blocking logic)
    var todayAllCompleted: Bool {
        let startOfTomorrow = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: .now)!)
        let today = tasks.filter { $0.dueDate < startOfTomorrow }
        return today.isEmpty || today.allSatisfy(\.isCompleted)
    }

    // MARK: - Sections

    var tasksBySection: [(title: String, tasks: [TaskItem])] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
        let startOfDayAfter = calendar.date(byAdding: .day, value: 2, to: startOfToday)!

        var sections: [(title: String, tasks: [TaskItem])] = [
            ("Today", tasks.filter { $0.dueDate < startOfTomorrow }),
            ("Tomorrow", tasks.filter { $0.dueDate >= startOfTomorrow && $0.dueDate < startOfDayAfter })
        ]

        let grouped = Dictionary(grouping: tasks.filter { $0.dueDate >= startOfDayAfter }) {
            calendar.startOfDay(for: $0.dueDate)
        }
        for date in grouped.keys.sorted() {
            sections.append((Self.sectionDateFormatter.string(from: date), grouped[date]!))
        }

        return sections
    }

    // MARK: - Persistence

    private func save() {
        TaskFileManager.saveTasks(tasks)
        WidgetCenter.shared.reloadTimelines(ofKind: "TodoWidget")
    }

    private func load() {
        tasks = TaskFileManager.loadTasks()
    }

    func reloadFromDisk() {
        tasks = TaskFileManager.loadTasks()
    }
}
