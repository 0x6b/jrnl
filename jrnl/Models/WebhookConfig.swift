//
//  WebhookConfig.swift
//  jrnl
//
//  Created by kaoru on 2025/10/13.
//

import Foundation

struct WebhookConfig: Codable, Identifiable {
    var id = UUID()
    var channelName: String
    var webhookURL: String
}
