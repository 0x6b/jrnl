//
//  WebhookEditSheet.swift
//  jrnl
//
//  Created by kaoru on 2025/10/13.
//

import SwiftUI

struct WebhookEditSheet: View {
    @ObservedObject var discordService: DiscordService
    let webhook: WebhookConfig?
    @Binding var isPresented: Bool

    @State private var channelName: String = ""
    @State private var webhookURL: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text(webhook == nil ? "Add Webhook" : "Edit Webhook")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("Channel Name")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("e.g., #general", text: $channelName)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Webhook URL")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("https://discord.com/api/webhooks/...", text: $webhookURL)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 12, design: .monospaced))
            }

            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button(webhook == nil ? "Add" : "Save") {
                    if let existingWebhook = webhook {
                        var updatedWebhook = existingWebhook
                        updatedWebhook.channelName = channelName
                        updatedWebhook.webhookURL = webhookURL
                        discordService.updateWebhook(updatedWebhook)
                    } else {
                        discordService.addWebhook(channelName: channelName, url: webhookURL)
                    }
                    isPresented = false
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .disabled(channelName.isEmpty || webhookURL.isEmpty)
            }
        }
        .padding()
        .frame(width: 450)
        .onAppear {
            if let webhook = webhook {
                channelName = webhook.channelName
                webhookURL = webhook.webhookURL
            }
        }
    }
}
