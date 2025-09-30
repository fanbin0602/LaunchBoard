//
//  VisualEffectView.swift
//  LaunchBoard
//
//  Created by 范斌 on 2025/9/29.
//


import SwiftUI

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        view.appearance = NSAppearance(named: .vibrantDark)

        // 透明背景
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor

        // 关闭触控事件（替代 acceptsTouchEvents）
        view.allowedTouchTypes = []

        view.alphaValue = 1.0
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.appearance = NSAppearance(named: .vibrantDark)
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator: NSObject {}
}
