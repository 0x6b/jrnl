//
//  DiscordService.swift
//  jrnl
//
//  Created by kaoru on 2025/10/13.
//

import Foundation
import Combine
import SwiftUI

struct WebhookConfig: Codable, Identifiable {
    var id = UUID()
    var channelName: String
    var webhookURL: String
}

@MainActor
class DiscordService: ObservableObject {
    @Published var webhooks: [WebhookConfig] = []

    private let userDefaults = UserDefaults.standard
    private let webhooksKey = "discord_webhooks"

    init() {
        loadWebhooks()
    }

    func saveWebhooks(_ webhooks: [WebhookConfig]) {
        self.webhooks = webhooks
        if let encoded = try? JSONEncoder().encode(webhooks) {
            userDefaults.set(encoded, forKey: webhooksKey)
        }
    }

    private func loadWebhooks() {
        if let data = userDefaults.data(forKey: webhooksKey),
           let decoded = try? JSONDecoder().decode([WebhookConfig].self, from: data) {
            webhooks = decoded
        }
    }

    func addWebhook(channelName: String, url: String) {
        let newWebhook = WebhookConfig(channelName: channelName, webhookURL: url)
        var updatedWebhooks = webhooks
        updatedWebhooks.append(newWebhook)
        saveWebhooks(updatedWebhooks)
    }

    func updateWebhook(_ webhook: WebhookConfig) {
        if let index = webhooks.firstIndex(where: { $0.id == webhook.id }) {
            var updatedWebhooks = webhooks
            updatedWebhooks[index] = webhook
            saveWebhooks(updatedWebhooks)
        }
    }

    func deleteWebhook(at offsets: IndexSet) {
        var updatedWebhooks = webhooks
        updatedWebhooks.remove(atOffsets: offsets)
        saveWebhooks(updatedWebhooks)
    }
    
    func sendMessage(_ content: String, toWebhookId webhookId: UUID? = nil) async throws {
        guard !webhooks.isEmpty else {
            throw DiscordError.noWebhookURL
        }

        let payload = DiscordMessage(content: content)

        // If a specific webhook is selected, send only to that one
        if let webhookId = webhookId {
            guard let webhook = webhooks.first(where: { $0.id == webhookId }) else {
                throw DiscordError.webhookNotFound
            }
            try await sendToWebhook(webhook: webhook, payload: payload)
            return
        }

        // Otherwise, send to all configured webhooks
        var errors: [(String, Error)] = []

        for webhook in webhooks {
            do {
                try await sendToWebhook(webhook: webhook, payload: payload)
            } catch {
                errors.append((webhook.channelName, error))
            }
        }

        // If all sends failed, throw an error
        if errors.count == webhooks.count {
            throw DiscordError.allWebhooksFailed(errors)
        }

        // If some sends failed, throw a partial error
        if !errors.isEmpty {
            throw DiscordError.someWebhooksFailed(errors)
        }
    }

    private func sendToWebhook(webhook: WebhookConfig, payload: DiscordMessage) async throws {
        guard let url = URL(string: webhook.webhookURL) else {
            throw DiscordError.invalidWebhookURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {
            throw DiscordError.encodingFailed
        }

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DiscordError.invalidResponse
        }

        guard 200...299 ~= httpResponse.statusCode else {
            throw DiscordError.httpError(httpResponse.statusCode)
        }
    }
}

struct DiscordMessage: Codable {
    let content: String
}

enum DiscordError: LocalizedError {
    case noWebhookURL
    case invalidWebhookURL
    case encodingFailed
    case invalidResponse
    case httpError(Int)
    case webhookNotFound
    case allWebhooksFailed([(String, Error)])
    case someWebhooksFailed([(String, Error)])

    var errorDescription: String? {
        switch self {
        case .noWebhookURL:
            return "No Discord webhooks configured"
        case .invalidWebhookURL:
            return "Invalid Discord webhook URL"
        case .encodingFailed:
            return "Failed to encode message"
        case .invalidResponse:
            return "Invalid response from Discord"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .webhookNotFound:
            return "Selected webhook not found"
        case .allWebhooksFailed(let errors):
            let errorList = errors.map { "\($0.0): \($0.1.localizedDescription)" }.joined(separator: "\n")
            return "All webhooks failed:\n\(errorList)"
        case .someWebhooksFailed(let errors):
            let errorList = errors.map { "\($0.0): \($0.1.localizedDescription)" }.joined(separator: "\n")
            return "Some webhooks failed:\n\(errorList)"
        }
    }
}