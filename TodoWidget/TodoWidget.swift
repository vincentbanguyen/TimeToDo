import WidgetKit
import SwiftUI

struct TodoWidget: Widget {
    let kind: String = "TodoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodoWidgetProvider()) { entry in
            TodoWidgetView(entry: entry)
        }
        .configurationDisplayName("Today's Tasks")
        .description("View and complete today's tasks.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
