import SwiftUI
import WidgetKit

struct TodoWidgetView: View {
    var entry: TodoEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: .spacingXS) {
            HStack {
                Text("Today's Tasks")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.colorTextPrimary)
                Spacer()
                Text(completionText)
                    .font(.fontCaption)
                    .foregroundColor(.colorTextSecondary)
            }
            .padding(.bottom, .spacingXS)

            if entry.tasks.isEmpty {
                Spacer()
                Text("No tasks for today")
                    .font(.fontBody)
                    .foregroundColor(.colorTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else {
                let visibleTasks = Array(entry.tasks.prefix(maxVisibleTasks))
                ForEach(visibleTasks) { task in
                    WidgetTaskRow(task: task)
                }

                let remaining = entry.tasks.count - visibleTasks.count
                if remaining > 0 {
                    Text("+\(remaining) more")
                        .font(.fontCaption)
                        .foregroundColor(.colorTextSecondary)
                }

                Spacer(minLength: 0)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private var maxVisibleTasks: Int {
        switch family {
        case .systemMedium: return 3
        case .systemLarge: return 7
        default: return 3
        }
    }

    private var completionText: String {
        let completed = entry.tasks.filter(\.isCompleted).count
        return "\(completed)/\(entry.tasks.count)"
    }
}

struct WidgetTaskRow: View {
    let task: TaskItem

    var body: some View {
        Button(intent: ToggleTaskIntent(taskID: task.id.uuidString)) {
            HStack(spacing: .spacingS) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(
                            task.isCompleted ? Color.colorSuccess : Color.colorBorder,
                            lineWidth: 1.5
                        )
                        .frame(width: 20, height: 20)

                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.colorSuccess)
                    }
                }

                Text(task.title)
                    .font(.fontBody)
                    .foregroundColor(task.isCompleted ? .colorTextSecondary : .colorTextPrimary)
                    .strikethrough(task.isCompleted)
                    .lineLimit(1)

                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}
