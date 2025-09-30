//
//  KeyboardHandler.swift
//  LaunchBoard
//
//  Created by 范斌 on 2025/9/29.
//


import SwiftUI

struct KeyboardHandler: NSViewRepresentable {
    var onEscape: () -> Void

    class Coordinator: NSObject {
        var onEscape: () -> Void

        init(onEscape: @escaping () -> Void) {
            self.onEscape = onEscape
        }

        @objc func keyDown(with event: NSEvent) {
            if event.keyCode == 53 { // ESC 键 keyCode
                onEscape()
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(onEscape: onEscape)
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 53 { // ESC
                context.coordinator.onEscape()
                return nil
            }
            return event
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

private extension NSView {
    func addLocalMonitorForEvents(matching mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent) -> NSEvent?) {
        NSEvent.addLocalMonitorForEvents(matching: mask, handler: handler)
    }
}
