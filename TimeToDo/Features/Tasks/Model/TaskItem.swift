import Foundation

struct TaskItem: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var dueDate: Date
    var lastModified: Date

    init(title: String, isCompleted: Bool = false, dueDate: Date = .now) {
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
        self.dueDate = Calendar.current.startOfDay(for: dueDate)
        self.lastModified = Date()
    }
}
