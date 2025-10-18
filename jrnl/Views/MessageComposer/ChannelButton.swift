//
//  ChannelButton.swift
//  jrnl
//
//  Created by kaoru on 2025/10/14.
//

import SwiftUI

struct ChannelButton: View {
    let webhooks: [WebhookConfig]
    @Binding var selectedWebhookId: UUID?

    var body: some View {
        Menu {
            ForEach(webhooks) { webhook in
                Button(action: {
                    selectedWebhookId = webhook.id
                }) {
                    Label {
                        Text(webhook.channelName)
                    } icon: {
                        if webhook.id == selectedWebhookId {
                            Image(systemName: "checkmark")
                        } else {
                            Image(systemName: "number")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 1) {
                Image(systemName: "number")
                    .font(.system(size: 10, weight: .medium))
                Text(displayText)
                    .font(.custom("iA Writer Duo S", size: 12))
            }
            .foregroundColor(.primary.opacity(0.8))
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
        .padding(.all, 7)
        .glassEffect(.clear, in: .rect(cornerRadius: 10))
        .help("Click to select channel")
    }

    private var displayText: String {
        if let currentWebhook = webhooks.first(where: { $0.id == selectedWebhookId }) {
            return currentWebhook.channelName
        } else {
            return "Select channel"
        }
    }
}

#Preview {
    @Previewable @State var selectedId: UUID? = nil
    let sampleWebhooks = [
        WebhookConfig(channelName: "general", webhookURL: "https://example.com/1"),
        WebhookConfig(channelName: "random", webhookURL: "https://example.com/2"),
        WebhookConfig(channelName: "announcements", webhookURL: "https://example.com/3")
    ]

    ZStack {
        Color.black.opacity(0.3)
        ChannelButton(webhooks: sampleWebhooks, selectedWebhookId: $selectedId)
            .padding(50)
    }
    .frame(width: 400, height: 300)
    .onAppear {
        selectedId = sampleWebhooks.first?.id
    }
}
