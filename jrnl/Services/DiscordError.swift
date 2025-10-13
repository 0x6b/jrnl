//
//  DiscordError.swift
//  jrnl
//
//  Created by kaoru on 2025/10/13.
//

import Foundation

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
