//
//  AppDelegate.swift
//  LaunchBoard
//
//  Created by 范斌 on 2025/9/29.
//


import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: LaunchBoardWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentView = ContentView()
        window = LaunchBoardWindow()
        window?.contentView = NSHostingView(rootView: contentView)
        window?.makeKeyAndOrderFront(nil)
    }
}
