//
//  DeviceActivityReport.swift
//  DeviceActivityReport
//
//  Created by Vincent Nguyen on 2/28/26.
//

import DeviceActivity
import ExtensionKit
import SwiftUI

@main
struct DeviceActivityReport: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        // Create a report for each DeviceActivityReport.Context that your app supports.
        TotalActivityReport { totalActivity in
            TotalActivityView(totalActivity: totalActivity)
        }
        // Add more reports here...
    }
}
