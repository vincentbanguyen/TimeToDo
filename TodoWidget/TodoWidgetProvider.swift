import WidgetKit
import SwiftUI

struct TodoEntry: TimelineEntry {
    let date: Date
    let tasks: [TaskItem]
}

struct TodoWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodoEntry {
        TodoEntry(date: .now, tasks: [
            TaskItem(title: "Complete your tasks..."),
            TaskItem(title: "To unlock your apps!", isCompleted: true)
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (TodoEntry) -> Void) {
        completion(TodoEntry(date: .now, tasks: TaskFileManager.todayTasks()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodoEntry>) -> Void) {
        let entry = TodoEntry(date: .now, tasks: TaskFileManager.todayTasks())
        let startOfTomorrow = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: .now)!
        )
        completion(Timeline(entries: [entry], policy: .after(startOfTomorrow)))
    }
}
