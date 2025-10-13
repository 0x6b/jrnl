//
//  SettingsView.swift
//  jrnl
//
//  Created by kaoru on 2025/10/13.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var discordService: DiscordService
    @Environment(\.dismiss) private var dismiss
    @State private var editingWebhook: WebhookConfig?
    @State private var showingAddSheet = false

    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack {
                Text("Settings")
                    .font(.headline)
                Spacer()
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            // Content
            Form {
                Section {
                    if discordService.webhooks.isEmpty {
                        Text("No webhooks configured")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    } else {
                        List {
                            ForEach(discordService.webhooks) { webhook in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(webhook.channelName)
                                            .font(.system(size: 13, weight: .medium))
                                        Text(webhook.webhookURL)
                                            .font(.system(size: 11, design: .monospaced))
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                            .truncationMode(.middle)
                                    }
                                    Spacer()
                                    Button("Edit") {
                                        editingWebhook = webhook
                                    }
                                    .buttonStyle(.borderless)
                                }
                            }
                            .onDelete { offsets in
                                discordService.deleteWebhook(at: offsets)
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }

                    Button("Add Webhook") {
                        showingAddSheet = true
                    }
                } header: {
                    Text("Discord Webhooks")
                } footer: {
                    Text("Get your webhook URL from Discord Server Settings > Integrations > Webhooks")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .formStyle(.grouped)

            Divider()

            // Buttons
            HStack {
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
        }
        .frame(width: 600, height: 500)
        .sheet(isPresented: $showingAddSheet) {
            WebhookEditSheet(discordService: discordService, webhook: nil, isPresented: $showingAddSheet)
        }
        .sheet(item: $editingWebhook) { webhook in
            WebhookEditSheet(discordService: discordService, webhook: webhook, isPresented: Binding(
                get: { editingWebhook != nil },
                set: { if !$0 { editingWebhook = nil } }
            ))
        }
    }
}

#Preview {
    SettingsView(discordService: DiscordService())
}
