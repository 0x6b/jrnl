//
//  View+HideScrollIndicators.swift
//  jrnl
//
//  Created by kaoru on 2025/10/13.
//

import SwiftUI
import AppKit

// Custom modifier to hide scrollbars in NSScrollView
struct HideScrollIndicators: ViewModifier {
    @State private var timer: Timer?

    func body(content: Content) -> some View {
        content
            .onAppear {
                // Run multiple times to catch dynamically created scroll views
                hideScrollbarsWithRetry()
            }
            .onDisappear {
                timer?.invalidate()
            }
    }

    private func hideScrollbarsWithRetry() {
        // Immediate execution
        hideScrollbars()

        // Retry after short delays to catch delayed scroll view creation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            hideScrollbars()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            hideScrollbars()
        }

        // Set up periodic check
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            hideScrollbars()
        }
    }

    private func hideScrollbars() {
        // Try all windows, not just key window
        for window in NSApplication.shared.windows {
            hideScrollbars(in: window.contentView)
        }
    }

    private func hideScrollbars(in view: NSView?) {
        guard let view = view else { return }

        if let scrollView = view as? NSScrollView {
            scrollView.hasVerticalScroller = false
            scrollView.hasHorizontalScroller = false
            scrollView.scrollerStyle = .overlay
            scrollView.verticalScroller?.alphaValue = 0
            scrollView.horizontalScroller?.alphaValue = 0
        }

        for subview in view.subviews {
            hideScrollbars(in: subview)
        }
    }
}

extension View {
    func hideScrollIndicators() -> some View {
        modifier(HideScrollIndicators())
    }
}
