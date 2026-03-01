import SwiftUI

struct EmptyTaskPlaceholderView: View {
    @Binding var isEditing: Bool
    @State private var taskText = ""
    @FocusState private var isFocused: Bool
    let onAddTask: (String) -> Void

    var body: some View {
        HStack(alignment: .center, spacing: .spacingM) {
            RoundedRectangle(cornerRadius: 4)
                .stroke(
                    Color.colorTextSecondary.opacity(isEditing ? 1.0 : 0.3),
                    style: isEditing
                        ? StrokeStyle(lineWidth: 1.5)
                        : StrokeStyle(lineWidth: 1.5, dash: [4, 4])
                )
                .frame(width: 24, height: 24)

            if isEditing {
                TextField("Add task...", text: $taskText)
                    .font(.fontBody)
                    .foregroundColor(.colorTextPrimary)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .onSubmit { submitTask() }
            } else {
                Text("Add task...")
                    .font(.fontBody)
                    .foregroundColor(.colorTextSecondary.opacity(0.6))
            }

            Spacer()

            if isEditing {
                Button("Cancel") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        taskText = ""
                        isEditing = false
                    }
                }
                .font(.fontBody)
                .foregroundColor(.colorTextSecondary)
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, .spacingS)
        .opacity(isEditing ? 1.0 : 0.7)
        .contentShape(Rectangle())
        .onTapGesture {
            if !isEditing {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isEditing = true
                }
            }
        }
        .onChange(of: isEditing) { _, editing in
            if editing { isFocused = true }
        }
    }

    private func submitTask() {
        let trimmed = taskText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onAddTask(trimmed)
        withAnimation(.easeInOut(duration: 0.2)) {
            taskText = ""
            isEditing = false
        }
    }
}
