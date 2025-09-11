//
//  ZenTimerWidgetExtensionBundle.swift
//  ZenTimerWidgetExtension
//
//  Created by Andrei Pop on 2025-09-11.
//

import ActivityKit
import WidgetKit
import SwiftUI

@main
struct ZenTimerWidgets: WidgetBundle {
    var body: some Widget {
        if #available(iOS 16.1, *) {
            ZenTimerWidgetExtensionLiveActivity()
        }
    }
}
