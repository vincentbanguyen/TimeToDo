//
//  TotalActivityView.swift
//  DeviceActivityReport
//
//  Created by Vincent Nguyen on 2/28/26.
//

import SwiftUI

struct TotalActivityView: View {
    let totalActivity: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "hourglass")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            Text("Total Screen Time")
                .font(.headline)
                .foregroundColor(.secondary)
            Text(totalActivity)
                .font(.system(size: 34, weight: .bold))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}

// In order to support previews for your extension's custom views, make sure its source files are
// members of your app's Xcode target as well as members of your extension's target. You can use
// Xcode's File Inspector to modify a file's Target Membership.
#Preview {
    TotalActivityView(totalActivity: "1h 23m")
}
