import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var store: TaskStore
    @AppStorage("hideCompletedTasks") private var hideCompletedTasks = true
    @State private var isAddingInline = false

    private func filteredTasks(_ tasks: [TaskItem]) -> [TaskItem] {
        hideCompletedTasks ? tasks.filter { !$0.isCompleted } : tasks
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.colorBackground.ignoresSafeArea()
                List {
                    // Inline add placeholder (adds to today)
                    EmptyTaskPlaceholderView(isEditing: $isAddingInline) { title in
                        store.addTask(title: title)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: .spacingL, bottom: 0, trailing: .spacingL))

                    // Date-based sections
                    ForEach(store.tasksBySection, id: \.title) { section in
                        let sectionTasks = filteredTasks(section.tasks)
                        if !sectionTasks.isEmpty {
                            Section {
                                ForEach(sectionTasks) { task in
                                    TaskItemView(
                                        task: task,
                                        onToggle: { store.toggleTask(task) },
                                        onUpdateTitle: { newTitle in
                                            store.updateTitle(task, to: newTitle)
                                        }
                                    )
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(EdgeInsets(top: 0, leading: .spacingL, bottom: 0, trailing: .spacingL))
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            store.deleteTask(task)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            } header: {
                                Text(section.title)
                                    .font(.fontHeading)
                                    .foregroundColor(.colorTextPrimary)
                                    .textCase(nil)
                                    .listRowInsets(EdgeInsets(top: .spacingM, leading: .spacingL, bottom: .spacingXS, trailing: .spacingL))
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .animation(.easeInOut(duration: 0.3), value: store.tasks)

            }
            .navigationTitle("TimeToDo")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Toggle("Hide Completed Tasks", isOn: $hideCompletedTasks)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.colorTextSecondary)
                    }
                }
            }
        }
    }
}
