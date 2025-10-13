//
//  PlainTextPasteHandler.swift
//  jrnl
//
//  Created by kaoru on 2025/10/13.
//

import AppKit
import ObjectiveC

// AssociatedKeys for storing paste monitor
private var pasteMonitorKey: UInt8 = 0

struct PlainTextPasteHandler {
    static func setup(for textView: NSTextView) {
        // Check if monitor already exists to avoid duplicate monitors
        if objc_getAssociatedObject(textView, &pasteMonitorKey) != nil {
            return
        }

        // Monitor paste events and convert to plain text
        let monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Check if this is Command+V (paste)
            if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "v" {
                // Get the first responder to check if it's our text view
                if NSApp.keyWindow?.firstResponder == textView {
                    // Get plain text from pasteboard
                    let pasteboard = NSPasteboard.general
                    if let plainText = pasteboard.string(forType: .string) {
                        // Insert plain text at current selection
                        textView.insertText(plainText, replacementRange: textView.selectedRange())
                        return nil // Consume the event
                    }
                }
            }
            return event
        }

        // Store monitor reference to prevent it from being deallocated
        if let monitor = monitor {
            objc_setAssociatedObject(textView, &pasteMonitorKey, monitor, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
