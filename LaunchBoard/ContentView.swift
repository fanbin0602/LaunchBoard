//
//  ContentView.swift
//  LaunchBoard
//
//  Created by 范斌 on 2025/9/29.
//

import SwiftUI
import AppKit

// MARK: - 数据模型
struct AppInfo: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let path: String
    let icon: NSImage
}

// MARK: - 主 ContentView
struct ContentView: View {
    @State private var apps: [AppInfo] = []
    @State private var searchText: String = ""
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    @State private var dragOffset: CGFloat = 0
    @State private var currentPage: Int = 0

    private let iconSize: CGFloat = 96
    private let horizontalSpacing: CGFloat = 96
    private let verticalSpacing: CGFloat = 40
    private let horizontalPadding: CGFloat = 96 * 1.5
    private let pageSpacing: CGFloat = 20

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height

            ZStack {
                // 背景毛玻璃
                VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                // 滚轮捕获（不拦截点击）
                ScrollCaptureView(onScroll: { deltaY in
                    handleScroll(deltaY: deltaY, screenWidth: screenWidth)
                })
                .allowsHitTesting(false)

                // 主内容
                VStack(spacing: 20) {
                    // 搜索框
                    TextField("", text: $searchText)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color.black.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .frame(maxWidth: 600)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )

                    if filteredApps.isEmpty {
                        Text("未找到应用")
                            .foregroundColor(.white.opacity(0.7))
                            .padding()
                    } else {
                        // 分页容器
                        ZStack {
                            HStack(spacing: pageSpacing) {
                                ForEach(pagedApps(screenWidth: screenWidth, screenHeight: screenHeight), id: \.self) { page in
                                    VStack(spacing: verticalSpacing) {
                                        ForEach(page, id: \.self) { row in
                                            HStack(spacing: horizontalSpacing) {
                                                ForEach(row) { app in
                                                    VStack {
                                                        Image(nsImage: app.icon)
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: iconSize, height: iconSize)
                                                            .cornerRadius(20)
                                                        Text(app.name)
                                                            .font(.caption)
                                                            .foregroundColor(.white)
                                                            .shadow(color: .black, radius: 2, x: 1, y: 1)
                                                            .lineLimit(1)
                                                    }
                                                    .onTapGesture { launchApp(app.path) }
                                                }
                                            }
                                            .frame(maxWidth: .infinity, alignment: .center)
                                        }
                                    }
                                    .frame(width: screenWidth)
                                }
                            }
                            .offset(x: -CGFloat(currentPage) * (screenWidth + pageSpacing) + dragOffset)
                            .simultaneousGesture(
                                DragGesture()
                                    .onChanged { value in dragOffset = value.translation.width }
                                    .onEnded { value in
                                        let threshold = screenWidth / 4
                                        var newPage = currentPage
                                        if value.predictedEndTranslation.width < -threshold {
                                            newPage = min(currentPage + 1, totalPages(screenWidth: screenWidth, screenHeight: screenHeight) - 1)
                                        } else if value.predictedEndTranslation.width > threshold {
                                            newPage = max(currentPage - 1, 0)
                                        }
                                        withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.85, blendDuration: 0.5)) {
                                            currentPage = newPage
                                            dragOffset = 0
                                        }
                                    }
                            )
                        }
                        .frame(width: screenWidth, height: screenHeight * 0.75)
                        .clipped()

                        // 分页指示器
                        HStack(spacing: 8) {
                            ForEach(0..<totalPages(screenWidth: screenWidth, screenHeight: screenHeight), id: \.self) { index in
                                Circle()
                                    .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                                    .frame(width: 8, height: 8)
                                    .onTapGesture {
                                        withAnimation(.easeInOut) { currentPage = index }
                                    }
                            }
                        }
                        .padding(.top, 8)

                    }
                }
                .padding()
                .scaleEffect(scale)
                .opacity(opacity)
            }
            .onAppear {
                loadApplications()
                withAnimation(.easeOut(duration: 0.25)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
            .background(KeyboardHandler(onEscape: hide))
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                withAnimation(.easeOut(duration: 0.25)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
        }
    }

    // MARK: - 数据处理
    var filteredApps: [AppInfo] {
        if searchText.isEmpty { return apps }
        return apps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    func flowRows(for apps: [AppInfo], availableWidth: CGFloat) -> [[AppInfo]] {
        var rows: [[AppInfo]] = []
        var currentRow: [AppInfo] = []
        var currentWidth: CGFloat = 0

        for app in apps {
            let addWidth = currentRow.isEmpty ? iconSize : iconSize + horizontalSpacing
            if currentWidth + addWidth > availableWidth && !currentRow.isEmpty {
                rows.append(currentRow)
                currentRow = [app]
                currentWidth = iconSize
            } else {
                currentRow.append(app)
                currentWidth += addWidth
            }
        }
        if !currentRow.isEmpty { rows.append(currentRow) }
        return rows
    }

    func pagedApps(screenWidth: CGFloat, screenHeight: CGFloat) -> [[[AppInfo]]] {
        let availableWidth = screenWidth - horizontalPadding * 2
        let availableHeight = screenHeight * 0.75
        let rowHeight = iconSize + verticalSpacing
        let rowsPerPage = max(Int(availableHeight / rowHeight), 1)

        let allRows = flowRows(for: filteredApps, availableWidth: availableWidth)
        var pages: [[[AppInfo]]] = []
        var currentPageRows: [[AppInfo]] = []

        for row in allRows {
            currentPageRows.append(row)
            if currentPageRows.count == rowsPerPage {
                pages.append(currentPageRows)
                currentPageRows = []
            }
        }
        if !currentPageRows.isEmpty { pages.append(currentPageRows) }

        return pages
    }

    func totalPages(screenWidth: CGFloat, screenHeight: CGFloat) -> Int {
        pagedApps(screenWidth: screenWidth, screenHeight: screenHeight).count
    }

    // MARK: - App 加载与启动
    private func loadApplications() {
        let appDirs = ["/Applications", NSHomeDirectory() + "/Applications", "/System/Applications"]
        var loadedApps: [AppInfo] = []

        for dir in appDirs {
            if let items = try? FileManager.default.contentsOfDirectory(atPath: dir) {
                for item in items where item.hasSuffix(".app") {
                    let path = "\(dir)/\(item)"
                    let name = (item as NSString).deletingPathExtension
                    let icon = NSWorkspace.shared.icon(forFile: path)
                    icon.size = NSSize(width: iconSize, height: iconSize)
                    loadedApps.append(AppInfo(name: name, path: path, icon: icon))
                }
            }
        }
        apps = loadedApps.sorted { $0.name < $1.name }
    }

    private func launchApp(_ path: String) {
        NSWorkspace.shared.open(URL(fileURLWithPath: path))
        hide()
    }

    private func hide() {
        withAnimation(.easeIn(duration: 0.25)) {
            scale = 0.8
            opacity = 0.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            NSApp.hide(nil)
        }
    }

    private func handleScroll(deltaY: CGFloat, screenWidth: CGFloat) {
        if deltaY < -0.5 {
            currentPage = min(currentPage + 1, totalPages(screenWidth: screenWidth, screenHeight: NSScreen.main?.frame.height ?? 1000) - 1)
        } else if deltaY > 0.5 {
            currentPage = max(currentPage - 1, 0)
        }
    }

}

#Preview {
    ContentView()
}
