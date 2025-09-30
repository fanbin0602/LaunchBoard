//
//  LaunchBoardWindow.swift
//  LaunchBoard
//
//  Created by 范斌 on 2025/9/29.
//


import SwiftUI
import AppKit

class LaunchBoardWindow: NSWindow {
    init() {
        // 获取主屏幕大小
        let screenSize = NSScreen.main?.frame ?? .zero
        super.init(
            contentRect: screenSize,
            styleMask: [.borderless],  // 无边框窗口
            backing: .buffered,
            defer: false
        )

        // 全屏覆盖
        self.setFrame(screenSize, display: true)
        self.isReleasedWhenClosed = false
        self.level = .floating  // 使用较低的窗口层级
        self.isOpaque = false
        self.backgroundColor = .clear
        self.collectionBehavior = [.canJoinAllSpaces]

        // 禁止被点击后失焦
        self.ignoresMouseEvents = false
        
        // 允许成为第一响应者，支持文本输入
        self.acceptsMouseMovedEvents = true
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
}

struct LaunchBoardWindowView<Content: View>: NSViewControllerRepresentable {
    let content: Content

    func makeNSViewController(context: Context) -> NSViewController {
        let hosting = NSHostingController(rootView: content)
        let window = LaunchBoardWindow()
        window.contentView = hosting.view
        let vc = NSViewController()
        vc.view = NSView(frame: window.frame)
        window.makeKeyAndOrderFront(nil)
        return vc
    }

    func updateNSViewController(_ nsViewController: NSViewController, context: Context) {}
}