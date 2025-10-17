//
//  jrnlApp.swift
//  jrnl
//
//  Created by kaoru on 2025/10/13.
//

import SwiftUI
import CoreText
import AppKit

@main
struct jrnlApp: App {
    @StateObject private var discordService = DiscordService()

    init() {
        registerFonts()
    }

    private func registerFonts() {
        let fontNames = [
            "iAWriterDuoS-Regular.ttf",
            "iAWriterDuoS-Bold.ttf",
            "iAWriterDuoS-Italic.ttf",
            "iAWriterDuoS-BoldItalic.ttf"
        ]

        for fontName in fontNames {
            // Try to find font in Fonts subdirectory first
            var fontURL = Bundle.main.url(forResource: fontName.replacingOccurrences(of: ".ttf", with: ""), withExtension: "ttf", subdirectory: "Fonts")

            // Fallback to root if not found
            if fontURL == nil {
                fontURL = Bundle.main.url(forResource: fontName.replacingOccurrences(of: ".ttf", with: ""), withExtension: "ttf")
            }

            if let fontURL = fontURL {
                var error: Unmanaged<CFError>?
                CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)
            }
        }

    }

    var body: some Scene {
        Window("jrnl", id: "main") {
            MessageComposerView()
                .frame(minWidth: 400, idealWidth: 600, minHeight: 150, idealHeight: 200)
                .environmentObject(discordService)
                .onAppear {
                    NSWindow.allowsAutomaticWindowTabbing = false
                }
        }
        .windowResizability(.contentMinSize)
        .windowStyle(.hiddenTitleBar)
        .commandsRemoved()
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Enter Full Screen") {
                    NSApp.keyWindow?.toggleFullScreen(nil)
                }
                .keyboardShortcut("f", modifiers: [.control, .command])
            }
        }

        Settings {
            SettingsView(discordService: discordService)
        }
    }
}
