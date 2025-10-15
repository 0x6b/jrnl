//
//  ChannelButton.swift
//  jrnl
//
//  Created by kaoru on 2025/10/14.
//

import SwiftUI

struct ChannelButton: View {
    let channelName: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 1) {
                Image(systemName: "number")
                    .font(.system(size: 10, weight: .medium))
                Text(displayText)
                    .font(.custom("iA Writer Duo S", size: 12))
            }
            .foregroundColor(.primary.opacity(0.8))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .glassEffect(.clear, in: .rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .focusable(false)
        .help("Click to select channel (⌘K)")
    }

    private var displayText: String {
        if let channelName {
            return channelName
        } else {
            return "Select channel"
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.3)
        VStack(spacing: 20) {
            ChannelButton(channelName: "general") { }
            ChannelButton(channelName: "random") { }
            ChannelButton(channelName: nil) { }
        }
        .padding(50)
    }
    .frame(width: 400, height: 300)
}
