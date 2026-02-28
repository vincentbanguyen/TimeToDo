//
//  ContentView.swift
//  TimeToDo
//
//  Created by Vincent Nguyen on 2/28/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Tasks", systemImage: "checklist") {
                TaskListView()
            }

            Tab("Block Apps", systemImage: "shield.lefthalf.filled") {
                BlockAppsView()
            }

            Tab("Screen Time", systemImage: "hourglass") {
                ScreenTimeView()
            }
        }
    }
}
