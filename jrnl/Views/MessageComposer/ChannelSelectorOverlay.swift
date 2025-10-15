//
//  ChannelSelectorOverlay.swift
//  jrnl
//
//  Created by kaoru on 2025/10/13.
//

import SwiftUI

struct ChannelSelectorOverlay: View {
    @EnvironmentObject private var discordService: DiscordService
    @Binding var showChannelMenu: Bool
    @Binding var selectedWebhookId: UUID?
    let onDismiss: () -> Void
    @State private var highlightedChannelIndex = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .onTapGesture {
                    showChannelMenu = false
                }

            GlassEffectContainer {
                VStack(spacing: 0) {
                ForEach(Array(discordService.webhooks.enumerated()), id: \.element.id) { index, webhook in
                    Button(action: {
                        selectedWebhookId = webhook.id
                        highlightedChannelIndex = index
                        showChannelMenu = false
                        onDismiss()
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
                    .background {
                        if index == highlightedChannelIndex {
                            Rectangle()
                                .fill(.tint.opacity(0.3))
                                .backgroundStyle(.selection)
                        } else if webhook.id == selectedWebhookId {
                            Rectangle()
                                .fill(.tint.opacity(0.15))
                                .backgroundStyle(.selection)
                        }
                    }
                    .help(index < 9 ? "Press \(index + 1) to select" : "")

                    if index < discordService.webhooks.count - 1 {
                        Divider()
                    }
                }
                }
                .frame(width: 300)
                .glassEffect(.regular, in: .rect(cornerRadius: 12))
            }
            .onAppear {
                // Set initial highlighted index to current selection
                if let currentIndex = self.discordService.webhooks.firstIndex(where: { $0.id == self.selectedWebhookId }) {
                    self.highlightedChannelIndex = currentIndex
                }

                NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    if self.showChannelMenu {
                        if event.keyCode == 53 { // Escape key
                            self.showChannelMenu = false
                            self.onDismiss()
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
                            self.onDismiss()
                            return nil
                        } else if let number = Int(event.charactersIgnoringModifiers ?? ""),
                                  number > 0 && number <= self.discordService.webhooks.count {
                            self.selectedWebhookId = self.discordService.webhooks[number - 1].id
                            self.showChannelMenu = false
                            self.onDismiss()
                            return nil
                        }
                    }
                    return event
                }
            }
        }
    }
}
