import SwiftUI

struct EmptyTaskPlaceholderView: View {
    @Binding var isEditing: Bool
    @State private var taskText = ""
    @State private var isAnimating = false
    let onAddTask: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: .spacingXS) {
            HStack(alignment: .center, spacing: .spacingM) {
                // Checkbox that animates from dashed to solid
                ZStack {
                    if isEditing {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.colorTextSecondary, lineWidth: 1.5)
                            .frame(width: 24, height: 24)
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: isAnimating)
                    } else {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.colorTextSecondary.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                            .frame(width: 24, height: 24)
                    }
                }

                // Text field or placeholder
                ZStack(alignment: .leading) {
                    if isEditing {
                        TextField("Add task...", text: $taskText)
                            .font(.fontBody)
                            .foregroundColor(.colorTextPrimary)
                            .textFieldStyle(.plain)
                            .onSubmit {
                                submitTask()
                            }
                    } else {
                        Text("Add task...")
                            .font(.fontBody)
                            .foregroundColor(.colorTextSecondary.opacity(0.6))
                    }
                }

                Spacer()

                // Cancel button
                Button("Cancel") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        taskText = ""
                        isEditing = false
                    }
                }
                .font(.fontBody)
                .foregroundColor(.colorTextSecondary)
                .opacity(isEditing ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.2), value: isEditing)
            }
            .padding(.vertical, .spacingS)
        }
        .opacity(isEditing ? 1.0 : 0.7)
        .contentShape(Rectangle())
        .onTapGesture {
            if !isEditing {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isEditing = true
                }
            }
        }
    }

    private func submitTask() {
        let trimmed = taskText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        taskText = ""

        withAnimation(.easeInOut(duration: 0.3)) {
            isAnimating = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            onAddTask(trimmed)
            isEditing = false
            isAnimating = false
        }
    }
}
