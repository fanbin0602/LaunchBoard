//
//  LaunchBoardApp.swift
//  LaunchBoard
//
//  Created by 范斌 on 2025/9/29.
//

import SwiftUI

@main
struct LaunchBoardApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // 不创建 WindowGroup，避免空白窗口
        Settings {} // 必须有个 Scene 占位，可以留空
    }
}
