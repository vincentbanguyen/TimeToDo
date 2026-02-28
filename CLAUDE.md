Workflow Orchestration
1. Plan Mode Default

Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
If something goes sideways, STOP and re-plan immediately – don't keep pushing
Use plan mode for verification steps, not just building
Write detailed specs upfront to reduce ambiguity

2. Subagent Strategy

Use subagents liberally to keep main context window clean
Offload research, exploration, and parallel analysis to subagents
For complex problems, throw more compute at it via subagents
One task per subagent for focused execution

3. Self-Improvement Loop

After ANY correction from the user: update tasks/lessons.md with the pattern
Write rules for yourself that prevent the same mistake
Ruthlessly iterate on these lessons until mistake rate drops
Review lessons at session start for relevant project

4. Verification Before Done

Never mark a task complete without proving it works
Diff behavior between main and your changes when relevant
Ask yourself: "Would a staff engineer approve this?"
Run tests, check logs, demonstrate correctness

5. Demand Elegance (Balanced)

For non-trivial changes: pause and ask "is there a more elegant way?"
If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
Skip this for simple, obvious fixes – don't over-engineer
Challenge your own work before presenting it

6. Autonomous Bug Fixing

When given a bug report: just fix it. Don't ask for hand-holding
Point at logs, errors, failing tests – then resolve them
Zero context switching required from the user
Go fix failing CI tests without being told how

Task Management

Plan First: Write plan to tasks/todo.md with checkable items
Verify Plan: Check in before starting implementation
Track Progress: Mark items complete as you go
Explain Changes: High-level summary at each step
Document Results: Add review section to tasks/todo.md
Capture Lessons: Update tasks/lessons.md after corrections

Core Principles

Simplicity First: Make every change as simple as possible. Impact minimal code.
No Laziness: Find root causes. No temporary fixes. Senior developer standards.
Minimal Impact: Changes should only touch what's necessary. Avoid introducing bugs.


# TimeToDo

Screen time blocker iOS app. Hard-blocks apps with a custom shield screen until the user completes a to-do from their task list. Completing a task unlocks apps.

## Stack

- Swift, SwiftUI
- FamilyControls / Screen Time API (ManagedSettings, DeviceActivity)
- Xcode project (no SPM/CocoaPods yet)

## Project Structure

```
TimeToDo/
├── App/
│   └── TimeToDoApp.swift
├── Features/
│   ├── Tasks/
│   │   ├── Model/
│   │   └── Views/
│   ├── AppBlocking/
│   │   ├── Model/
│   │   └── Views/
│   └── Shield/
│       ├── Model/
│       └── Views/
├── Shared/
│   ├── Model/
│   ├── Views/
│   └── Extensions/
├── ShieldExtension/
├── DeviceActivityMonitorExtension/
└── Assets.xcassets
```

Each feature owns its Model and Views. Shared holds reusable components, common models (e.g. app group storage), and extensions.

## Key Concepts

- **FamilyControls** — request authorization to manage screen time
- **ManagedSettings** — apply/remove app shields (ShieldSettings store)
- **DeviceActivity** — schedule monitoring intervals
- Shield UI extension provides custom block screen with task prompt

## MVP Phases

1. **Project Structure + Task Management** — folder setup, TaskItem model, TaskStore (CRUD + persistence), TaskListView, AddTaskView. Pure SwiftUI, no Screen Time APIs.
2. **FamilyControls Auth + App Picker** — FamilyControls capability, AuthorizationManager, FamilyActivityPicker for app selection, store selection in App Group.
3. **App Blocking (ManagedSettings)** — BlockingManager shields/unshields apps via ManagedSettingsStore. Wire to TaskStore: all tasks done → unblock, new task → re-block.
4. **Shield Extension** — ShieldConfigurationExtension + ShieldActionExtension targets. Custom block screen with "Open TimeToDo" deep link.
5. **Polish + E2E Flow** — Onboarding (auth → pick apps → add task), auto-block on launch, deep link handling, empty states, error handling.
6. add results tab where user can view how screentime has improved.

## Dev Notes

- Requires physical device for Screen Time API testing (simulator unsupported)
- Must enable FamilyControls capability + app group for shared data between app and extensions
- Target iOS 16+
