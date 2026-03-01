import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var store: TaskStore
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var dueDate = Date()
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: .spacingM) {
                TextField("What do you need to do?", text: $title)
                    .font(.fontHeading)
                    .foregroundColor(.colorTextPrimary)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .onSubmit {
                        addAndDismiss()
                    }

                DatePicker(
                    "Due Date",
                    selection: $dueDate,
                    in: Calendar.current.startOfDay(for: .now)...,
                    displayedComponents: .date
                )
                .font(.fontBody)
                .foregroundColor(.colorTextPrimary)

                Spacer()
            }
            .padding(.spacingL)
            .background(Color.colorBackground)
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { addAndDismiss() }
                        .fontWeight(.semibold)
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            isFocused = true
        }
    }

    private func addAndDismiss() {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        store.addTask(title: title, dueDate: dueDate)
        dismiss()
    }
}
