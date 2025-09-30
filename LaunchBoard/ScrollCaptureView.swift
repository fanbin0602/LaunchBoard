//
//  ScrollCaptureView.swift
//  LaunchBoard
//
//  Created by 范斌 on 2025/9/29.
//

import SwiftUI


struct ScrollCaptureView: NSViewRepresentable {
    var onScroll: (CGFloat) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = ScrollCaptureNSView()
        view.onScroll = onScroll
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

class ScrollCaptureNSView: NSView {
    var onScroll: ((CGFloat) -> Void)?
    private var eventMonitor: Any?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if window != nil {
            setupEventMonitor()
        } else {
            removeEventMonitor()
        }
    }
    
    private func setupEventMonitor() {
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { [weak self] event in
            self?.onScroll?(event.deltaY)
            return event
        }
    }
    
    private func removeEventMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
    
    deinit {
        removeEventMonitor()
    }
}
