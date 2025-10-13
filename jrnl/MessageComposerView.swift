//
//  SpotlightView.swift
//  jrnl
//
//  Created by kaoru on 2025/10/13.
//

import SwiftUI
import Combine
import HighlightedTextEditor
import AppKit
import ObjectiveC

// AssociatedKeys for storing paste monitor
private var pasteMonitorKey: UInt8 = 0

// Custom modifier to hide scrollbars in NSScrollView
struct HideScrollIndicators: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                DispatchQueue.main.async {
                    hideScrollbars()
                }
            }
    }

    private func hideScrollbars() {
        guard let window = NSApplication.shared.keyWindow else { return }
        hideScrollbars(in: window.contentView)
    }

    private func hideScrollbars(in view: NSView?) {
        guard let view = view else { return }

        if let scrollView = view as? NSScrollView {
            scrollView.hasVerticalScroller = false
            scrollView.hasHorizontalScroller = false
            scrollView.scrollerStyle = .overlay
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

struct MessageComposerView: View {
    @EnvironmentObject private var discordService: DiscordService
    @State private var messageText = ""
    @State private var isSending = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var selectedWebhookId: UUID? = nil
    @FocusState private var isTextFieldFocused: Bool
    @State private var showChannelMenu = false
    @State private var highlightedChannelIndex = 0

    private let customFont = NSFont(name: "iA Writer Duo S", size: 14) ?? .monospacedSystemFont(ofSize: 14, weight: .regular)

    private var customBoldFont: NSFont {
        let fontManager = NSFontManager.shared
        var font = fontManager.convert(customFont, toHaveTrait: .boldFontMask)
        font = fontManager.convert(font, toHaveTrait: .expandedFontMask)
        return font
    }

    private var customBoldOnlyFont: NSFont {
        return NSFontManager.shared.convert(customFont, toHaveTrait: .boldFontMask)
    }

    private var customItalicFont: NSFont {
        return NSFontManager.shared.convert(customFont, toHaveTrait: .italicFontMask)
    }

    private var customBoldItalicFont: NSFont {
        let fontManager = NSFontManager.shared
        let boldFont = fontManager.convert(customFont, toHaveTrait: .boldFontMask)
        return fontManager.convert(boldFont, toHaveTrait: .italicFontMask)
    }

    private var markdownRules: [HighlightRule] {
        // Base font for all text
        let baseFontRule = HighlightRule(pattern: .all, formattingRule: TextFormattingRule(key: .font, value: customFont))

        // Custom markdown rules with equal font sizes
        let inlineCodeRegex = try! NSRegularExpression(pattern: "`[^`]*`", options: [])
        let codeBlockRegex = try! NSRegularExpression(pattern: "(`){3}((?!\\1).)+\\1{3}", options: [.dotMatchesLineSeparators])
        let headingRegex = try! NSRegularExpression(pattern: "^#{1,6}\\s.*$", options: [.anchorsMatchLines])
        let linkOrImageRegex = try! NSRegularExpression(pattern: "!?\\[([^\\[\\]]*)\\]\\((.*?)\\)", options: [])
        let linkOrImageTagRegex = try! NSRegularExpression(pattern: "!?\\[([^\\[\\]]*)\\]\\[(.*?)\\]", options: [])
        let boldRegex = try! NSRegularExpression(pattern: "((\\*|_){2})((?!\\1).)+\\1", options: [])
        let underscoreEmphasisRegex = try! NSRegularExpression(pattern: "(?<!_)_[^_]+_(?!\\*)", options: [])
        let asteriskEmphasisRegex = try! NSRegularExpression(pattern: "(?<!\\*)(\\*)((?!\\1).)+\\1(?!\\*)", options: [])
        let boldEmphasisAsteriskRegex = try! NSRegularExpression(pattern: "(\\*){3}((?!\\1).)+\\1{3}", options: [])
        let blockquoteRegex = try! NSRegularExpression(pattern: "^>.*", options: [.anchorsMatchLines])
        let horizontalRuleRegex = try! NSRegularExpression(pattern: "\n\n(-{3}|\\*{3})\n", options: [])
        let unorderedListRegex = try! NSRegularExpression(pattern: "^(\\-|\\*)\\s", options: [.anchorsMatchLines])
        let orderedListRegex = try! NSRegularExpression(pattern: "^\\d*\\.\\s", options: [.anchorsMatchLines])
        let strikethroughRegex = try! NSRegularExpression(pattern: "(~)((?!\\1).)+\\1", options: [])
        let tagRegex = try! NSRegularExpression(pattern: "^\\[([^\\[\\]]*)\\]:", options: [.anchorsMatchLines])
        let footnoteRegex = try! NSRegularExpression(pattern: "\\[\\^(.*?)\\]", options: [])
        let htmlRegex = try! NSRegularExpression(pattern: "<([A-Z][A-Z0-9]*)\\b[^>]*>(.*?)</\\1>", options: [.dotMatchesLineSeparators, .caseInsensitive])

        let secondaryBackground = NSColor.windowBackgroundColor
        let lighterColor = NSColor.lightGray
        let textColor = NSColor.labelColor

        return [
            baseFontRule,
            HighlightRule(pattern: inlineCodeRegex, formattingRule: TextFormattingRule(key: .font, value: customFont)),
            HighlightRule(pattern: codeBlockRegex, formattingRule: TextFormattingRule(key: .font, value: customFont)),
            HighlightRule(pattern: headingRegex, formattingRules: [
                TextFormattingRule(key: .font, value: customBoldFont),
                TextFormattingRule(key: .kern, value: 0.5)
            ]),
            HighlightRule(pattern: linkOrImageRegex, formattingRule: TextFormattingRule(key: .underlineStyle, value: NSUnderlineStyle.single.rawValue)),
            HighlightRule(pattern: linkOrImageTagRegex, formattingRule: TextFormattingRule(key: .underlineStyle, value: NSUnderlineStyle.single.rawValue)),
            HighlightRule(pattern: boldRegex, formattingRule: TextFormattingRule(key: .font, value: customBoldOnlyFont)),
            HighlightRule(pattern: asteriskEmphasisRegex, formattingRule: TextFormattingRule(key: .font, value: customItalicFont)),
            HighlightRule(pattern: underscoreEmphasisRegex, formattingRule: TextFormattingRule(key: .font, value: customItalicFont)),
            HighlightRule(pattern: boldEmphasisAsteriskRegex, formattingRule: TextFormattingRule(key: .font, value: customBoldItalicFont)),
            HighlightRule(pattern: blockquoteRegex, formattingRule: TextFormattingRule(key: .backgroundColor, value: secondaryBackground)),
            HighlightRule(pattern: horizontalRuleRegex, formattingRule: TextFormattingRule(key: .foregroundColor, value: lighterColor)),
            HighlightRule(pattern: unorderedListRegex, formattingRule: TextFormattingRule(key: .foregroundColor, value: lighterColor)),
            HighlightRule(pattern: orderedListRegex, formattingRule: TextFormattingRule(key: .foregroundColor, value: lighterColor)),
            HighlightRule(pattern: strikethroughRegex, formattingRules: [
                TextFormattingRule(key: .strikethroughStyle, value: NSUnderlineStyle.single.rawValue),
                TextFormattingRule(key: .strikethroughColor, value: textColor)
            ]),
            HighlightRule(pattern: tagRegex, formattingRule: TextFormattingRule(key: .foregroundColor, value: lighterColor)),
            HighlightRule(pattern: footnoteRegex, formattingRule: TextFormattingRule(key: .foregroundColor, value: lighterColor)),
            HighlightRule(pattern: htmlRegex, formattingRules: [
                TextFormattingRule(key: .font, value: customFont),
                TextFormattingRule(key: .foregroundColor, value: lighterColor)
            ])
        ]
    }

    private var webhookOptions: [UUID?] {
        discordService.webhooks.map { $0.id }
    }

    var body: some View {
        ZStack {
            textInputView
                .overlay(
                    Group {
                        if isSending {
                            ZStack {
                                Color.black.opacity(0.3)
                                ProgressView()
                            }
                        }
                    }
                )
                .overlay(
                    Group {
                        if showChannelMenu {
                            channelSelectorOverlay
                        }
                    }
                )

            // Invisible button for keyboard shortcut
            Button(action: {
                Task {
                    await sendMessage()
                }
            }) {
                EmptyView()
            }
            .keyboardShortcut(.return, modifiers: [.command])
            .hidden()

            // Navigate previous webhook
            Button(action: {
                selectPreviousWebhook()
            }) {
                EmptyView()
            }
            .keyboardShortcut(.upArrow, modifiers: [.command, .control])
            .hidden()

            // Navigate next webhook
            Button(action: {
                selectNextWebhook()
            }) {
                EmptyView()
            }
            .keyboardShortcut(.downArrow, modifiers: [.command, .control])
            .hidden()

            // Show channel menu
            Button(action: {
                showChannelMenu.toggle()
            }) {
                EmptyView()
            }
            .keyboardShortcut("k", modifiers: [.command])
            .hidden()
        }
        .onAppear {
            isTextFieldFocused = true
            if selectedWebhookId == nil {
                selectedWebhookId = discordService.webhooks.first?.id
            }
            updateWindowTitle()
        }
        .onChange(of: selectedWebhookId) {
            updateWindowTitle()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            isTextFieldFocused = true
        }
        .alert("Message Status", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var textInputView: some View {
        ZStack(alignment: .topLeading) {
            HighlightedTextEditor(text: $messageText, highlightRules: markdownRules)
                .introspect { internals in
                    // Disable automatic link detection to preserve markdown
                    internals.textView.isAutomaticLinkDetectionEnabled = false
                    internals.textView.isAutomaticTextReplacementEnabled = false

                    // Set up plain text paste behavior
                    setupPlainTextPaste(for: internals.textView)
                }
                .focused($isTextFieldFocused)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Placeholder text
            if messageText.isEmpty {
                Text(placeholderText)
                    .font(.custom("iA Writer Duo S", size: 14))
                    .foregroundColor(.secondary.opacity(0.5))
                    .allowsHitTesting(false)
                    .padding(.leading, 5)
            }
        }
        .padding(12)
        .hideScrollIndicators()
    }

    private var placeholderText: String {
        if let channelName = discordService.webhooks.first(where: { $0.id == selectedWebhookId })?.channelName {
            return "Message #\(channelName)"
        } else {
            return "Select a channel to start messaging"
        }
    }

    private func setupPlainTextPaste(for textView: NSTextView) {
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

    private var channelSelectorOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .onTapGesture {
                    showChannelMenu = false
                }

            VStack(spacing: 0) {
                ForEach(Array(discordService.webhooks.enumerated()), id: \.element.id) { index, webhook in
                    Button(action: {
                        selectedWebhookId = webhook.id
                        highlightedChannelIndex = index
                        showChannelMenu = false
                        isTextFieldFocused = true
                    }) {
                        HStack {
                            Text(webhook.channelName)
                                .font(.system(size: 14))
                            Spacer()
                            if webhook.id == selectedWebhookId {
                                Image(systemName: "checkmark")
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .background(
                        index == highlightedChannelIndex ?
                            Color.accentColor.opacity(0.4) :
                            (webhook.id == selectedWebhookId ? Color.accentColor.opacity(0.2) : Color.clear)
                    )
                    .help(index < 9 ? "Press \(index + 1) to select" : "")

                    if index < discordService.webhooks.count - 1 {
                        Divider()
                    }
                }
            }
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .shadow(radius: 10)
            .frame(width: 300)
            .onAppear {
                // Set initial highlighted index to current selection
                if let currentIndex = self.discordService.webhooks.firstIndex(where: { $0.id == self.selectedWebhookId }) {
                    self.highlightedChannelIndex = currentIndex
                }

                NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    if self.showChannelMenu {
                        if event.keyCode == 53 { // Escape key
                            self.showChannelMenu = false
                            self.isTextFieldFocused = true
                            return nil
                        } else if event.keyCode == 126 { // Up arrow
                            if self.highlightedChannelIndex > 0 {
                                self.highlightedChannelIndex -= 1
                            } else {
                                self.highlightedChannelIndex = self.discordService.webhooks.count - 1
                            }
                            return nil
                        } else if event.keyCode == 125 { // Down arrow
                            if self.highlightedChannelIndex < self.discordService.webhooks.count - 1 {
                                self.highlightedChannelIndex += 1
                            } else {
                                self.highlightedChannelIndex = 0
                            }
                            return nil
                        } else if event.keyCode == 36 { // Return/Enter key
                            self.selectedWebhookId = self.discordService.webhooks[self.highlightedChannelIndex].id
                            self.showChannelMenu = false
                            self.isTextFieldFocused = true
                            return nil
                        } else if let number = Int(event.charactersIgnoringModifiers ?? ""),
                                  number > 0 && number <= self.discordService.webhooks.count {
                            self.selectedWebhookId = self.discordService.webhooks[number - 1].id
                            self.showChannelMenu = false
                            self.isTextFieldFocused = true
                            return nil
                        }
                    }
                    return event
                }
            }
        }
    }

    private func sendMessage() async {
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }

        isSending = true

        do {
            try await discordService.sendMessage(trimmedMessage, toWebhookId: selectedWebhookId)
            messageText = ""
        } catch {
            alertMessage = "Failed to send message: \(error.localizedDescription)"
            showingAlert = true
        }

        isSending = false

        // Refocus the text field
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isTextFieldFocused = true
        }
    }

    private func selectPreviousWebhook() {
        let options = webhookOptions
        guard !options.isEmpty else { return }

        if let currentIndex = options.firstIndex(where: { $0 == selectedWebhookId }) {
            let previousIndex = currentIndex == 0 ? options.count - 1 : currentIndex - 1
            selectedWebhookId = options[previousIndex]
        } else {
            selectedWebhookId = options.first ?? nil
        }
    }

    private func selectNextWebhook() {
        let options = webhookOptions
        guard !options.isEmpty else { return }

        if let currentIndex = options.firstIndex(where: { $0 == selectedWebhookId }) {
            let nextIndex = (currentIndex + 1) % options.count
            selectedWebhookId = options[nextIndex]
        } else {
            selectedWebhookId = options.first ?? nil
        }
    }

    private func updateWindowTitle() {
        if let channelName = discordService.webhooks.first(where: { $0.id == selectedWebhookId })?.channelName {
            NSApp.keyWindow?.title = "jrnl - #\(channelName)"
        } else {
            NSApp.keyWindow?.title = "jrnl"
        }
    }
}

#Preview {
    MessageComposerView()
        .environmentObject(DiscordService())
        .padding(50)
        .background(.black.opacity(0.3))
}
