import AppIntents
import WidgetKit

struct ToggleTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Task"
    static var description = IntentDescription("Toggles a task's completion state")

    @Parameter(title: "Task ID")
    var taskID: String

    init() {}

    init(taskID: String) {
        self.taskID = taskID
    }

    func perform() async throws -> some IntentResult {
        guard let uuid = UUID(uuidString: taskID) else {
            return .result()
        }

        var tasks = TaskFileManager.loadTasks()
        if let index = tasks.firstIndex(where: { $0.id == uuid }) {
            tasks[index].isCompleted.toggle()
            tasks[index].lastModified = Date()
            TaskFileManager.saveTasks(tasks)
        }

        WidgetCenter.shared.reloadTimelines(ofKind: "TodoWidget")

        let name = "com.ravinlabsdev.TimeToDo.tasksChanged" as CFString
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(name),
            nil, nil, true
        )

        return .result()
    }
}
