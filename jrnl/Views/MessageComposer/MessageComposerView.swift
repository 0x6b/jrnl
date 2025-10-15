//
//  MessageComposerView.swift
//  jrnl
//
//  Created by kaoru on 2025/10/13.
//

import SwiftUI
import Combine
import HighlightedTextEditor
import AppKit

struct MessageComposerView: View {
    @EnvironmentObject private var discordService: DiscordService
    @State private var messageText = ""
    @State private var isSending = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var selectedWebhookId: UUID? = nil
    @FocusState private var isTextFieldFocused: Bool
    @State private var showChannelMenu = false

    private let customFont = NSFont(name: "iAWriterDuoS-Regular", size: 14) ?? .monospacedSystemFont(ofSize: 14, weight: .regular)

    private var markdownRules: [HighlightRule] {
        MarkdownHighlighting.rules(for: customFont)
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
                            ChannelSelectorOverlay(
                                showChannelMenu: $showChannelMenu,
                                selectedWebhookId: $selectedWebhookId,
                                onDismiss: { isTextFieldFocused = true }
                            )
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
        ZStack(alignment: .bottomTrailing) {
            HighlightedTextEditor(text: $messageText, highlightRules: markdownRules)
                .introspect { internals in
                    // Set font immediately to ensure correct cursor size
                    // internals.textView.font = customFont

                    // Disable automatic link detection to preserve markdown
                    internals.textView.isAutomaticLinkDetectionEnabled = false
                    internals.textView.isAutomaticTextReplacementEnabled = false

                    // Set up plain text paste behavior
                    PlainTextPasteHandler.setup(for: internals.textView)
                }
                .focused($isTextFieldFocused)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Channel button with liquid glass effect - always visible in bottom-right
            ChannelButton(
                channelName: discordService.webhooks.first(where: { $0.id == selectedWebhookId })?.channelName,
                action: { showChannelMenu.toggle() }
            )
            .padding(.trailing, 8)
            .padding(.bottom, 8)
        }
        .padding(12)
        .hideScrollIndicators()
    }

    private var placeholderText: String {
        if let channelName = discordService.webhooks.first(where: { $0.id == selectedWebhookId })?.channelName {
            return "#\(channelName)"
        } else {
            return "Select a channel to start messaging"
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
