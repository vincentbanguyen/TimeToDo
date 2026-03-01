import SwiftUI
import FamilyControls

struct TaskListView: View {
    @EnvironmentObject var store: TaskStore
    @EnvironmentObject var authManager: AuthorizationManager
    @EnvironmentObject var selectionManager: AppSelectionManager
    @EnvironmentObject var blockingManager: BlockingManager
    @AppStorage("hideCompletedTasks") private var hideCompletedTasks = true
    @State private var showingAddTask = false
    @State private var showingSettings = false
    @State private var showingAppPicker = false
    @State private var isEditingToday = false
    @State private var isEditingTomorrow = false
    @State private var keyboardVisible = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.colorBackground.ignoresSafeArea()

                List {
                    bannerRow
                    taskSections
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .animation(.easeInOut(duration: 0.3), value: store.tasks)

                fabButton
                    .opacity(isEditingToday || isEditingTomorrow || keyboardVisible ? 0 : 1)
                    .scaleEffect(isEditingToday || isEditingTomorrow || keyboardVisible ? 0.8 : 1)
                    .allowsHitTesting(!isEditingToday && !isEditingTomorrow && !keyboardVisible)
                    .animation(.easeInOut(duration: 0.25), value: keyboardVisible)
                    .animation(.easeInOut(duration: 0.25), value: isEditingToday)
                    .animation(.easeInOut(duration: 0.25), value: isEditingTomorrow)
            }
            .navigationTitle("TimeToDo")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingSettings = true } label: {
                        Image(systemName: "gearshape")
                            .foregroundColor(.colorTextSecondary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView().environmentObject(store)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingAppPicker) {
            NavigationStack {
                FamilyActivityPicker(selection: $selectionManager.selection)
                    .navigationTitle("Apps to Block")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showingAppPicker = false }
                        }
                    }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            keyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
            keyboardVisible = false
        }
    }

    // MARK: - Banner

    private var bannerRow: some View {
        Button {
            if authManager.isAuthorized {
                showingAppPicker = true
            } else {
                Task { await authManager.requestAuthorization() }
            }
        } label: {
            BlockingStatusBanner()
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: .spacingM, leading: .spacingL, bottom: .spacingM, trailing: .spacingL))
        .listRowSeparator(.hidden)
    }

    // MARK: - Task Sections

    private var taskSections: some View {
        ForEach(store.tasksBySection, id: \.title) { section in
            let tasks = hideCompletedTasks ? section.tasks.filter { !$0.isCompleted } : section.tasks
            let isInlineSection = section.title == "Today" || section.title == "Tomorrow"

            if !tasks.isEmpty || isInlineSection {
                Section {
                    ForEach(tasks) { task in
                        taskRow(task)
                    }
                    if isInlineSection {
                        inlineAddRow(section: section.title)
                    }
                } header: {
                    sectionHeader(section.title)
                }
            }
        }
    }

    private func taskRow(_ task: TaskItem) -> some View {
        TaskItemView(
            task: task,
            onToggle: { store.toggleTask(task) },
            onUpdateTitle: { store.updateTitle(task, to: $0) }
        )
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 0, leading: .spacingL, bottom: 0, trailing: .spacingL))
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) { store.deleteTask(task) } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func inlineAddRow(section: String) -> some View {
        EmptyTaskPlaceholderView(isEditing: section == "Tomorrow" ? $isEditingTomorrow : $isEditingToday) { title in
            let dueDate: Date = section == "Tomorrow"
                ? Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: .now))!
                : .now
            store.addTask(title: title, dueDate: dueDate)
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 0, leading: .spacingL, bottom: 0, trailing: .spacingL))
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.fontHeading)
            .foregroundColor(.colorTextPrimary)
            .textCase(nil)
            .listRowInsets(EdgeInsets(top: .spacingM, leading: .spacingL, bottom: .spacingXS, trailing: .spacingL))
    }

    // MARK: - FAB

    private var fabButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button { showingAddTask = true } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.colorPrimary)
                        .clipShape(Circle())
                        .elevationHigh()
                }
                .padding(.trailing, .spacingL)
                .padding(.bottom, .spacingXL)
            }
        }
    }
}

// MARK: - Blocking Status Banner

private struct BlockingStatusBanner: View {
    @EnvironmentObject var authManager: AuthorizationManager
    @EnvironmentObject var selectionManager: AppSelectionManager
    @EnvironmentObject var blockingManager: BlockingManager
    @EnvironmentObject var store: TaskStore
    @AppStorage("blockingDisabled") private var blockingDisabled = false

    private var totalIcons: Int {
        selectionManager.selection.applicationTokens.count
        + selectionManager.selection.categoryTokens.count
        + selectionManager.selection.webDomainTokens.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .spacingS) {
            HStack(spacing: .spacingM) {
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
                    .font(.system(size: 20, weight: .medium))

                Text(statusText)
                    .font(.fontBody)
                    .foregroundColor(.colorTextSecondary)

                if blockingManager.isBlocking && totalIcons <= 6 {
                    iconRow
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.colorTextSecondary.opacity(0.5))
            }

            if blockingManager.isBlocking && totalIcons > 6 {
                ScrollView(.horizontal, showsIndicators: false) {
                    iconRow
                }
            }
        }
    }

    private var iconName: String {
        if blockingDisabled { return "lock.open" }
        if !authManager.isAuthorized || !selectionManager.hasSelection {
            return "lock.open"
        }
        return blockingManager.isBlocking ? "lock.fill" : "lock.open"
    }

    private var iconColor: Color {
        if blockingDisabled { return .colorTextSecondary }
        if !authManager.isAuthorized || !selectionManager.hasSelection {
            return .colorWarning
        }
        return blockingManager.isBlocking ? .colorSuccess : .colorTextSecondary
    }

    private var statusText: String {
        if blockingDisabled { return "Blocking disabled" }
        if !authManager.isAuthorized { return "Set up app blocking" }
        if !selectionManager.hasSelection { return "No apps selected" }
        if store.todayAllCompleted { return "All tasks done. All apps unlocked!" }
        return "Blocking"
    }

    private var iconRow: some View {
        HStack(spacing: 6) {
            ForEach(Array(selectionManager.selection.applicationTokens), id: \.self) { token in
                Label(token).labelStyle(.iconOnly).frame(width: 28, height: 28)
            }
            ForEach(Array(selectionManager.selection.categoryTokens), id: \.self) { token in
                Label(token).labelStyle(.iconOnly).frame(width: 28, height: 28)
            }
            ForEach(Array(selectionManager.selection.webDomainTokens), id: \.self) { token in
                Label(token).labelStyle(.iconOnly).frame(width: 28, height: 28)
            }
        }
    }
}
