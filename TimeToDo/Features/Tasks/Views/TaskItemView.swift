import SwiftUI

private struct InstantButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct TaskItemView: View {
    let task: TaskItem
    let onToggle: () -> Void
    let onUpdateTitle: (String) -> Void

    @State private var editableTitle: String
    @FocusState private var titleFieldFocused: Bool

    init(task: TaskItem, onToggle: @escaping () -> Void, onUpdateTitle: @escaping (String) -> Void) {
        self.task = task
        self.onToggle = onToggle
        self.onUpdateTitle = onUpdateTitle
        self._editableTitle = State(initialValue: task.title)
    }

    var body: some View {
        HStack(alignment: .center, spacing: .spacingM) {
            Button(action: onToggle) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(task.isCompleted ? Color.colorSuccess : Color.colorBorder, lineWidth: 1.5)
                        .frame(width: 24, height: 24)

                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.colorSuccess)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(InstantButtonStyle())

            TextField("Task title", text: $editableTitle)
                .font(.fontBody)
                .foregroundColor(task.isCompleted ? .colorTextSecondary : .colorTextPrimary)
                .textFieldStyle(.plain)
                .focused($titleFieldFocused)
                .strikethrough(task.isCompleted)
                .animation(.easeInOut(duration: 0.3), value: task.isCompleted)
                .onSubmit {
                    onUpdateTitle(editableTitle)
                    titleFieldFocused = false
                }

            Spacer()
        }
        .padding(.vertical, .spacingS)
    }
}
