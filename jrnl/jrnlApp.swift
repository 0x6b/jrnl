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
            if let fontURL = Bundle.main.url(forResource: fontName.replacingOccurrences(of: ".ttf", with: ""), withExtension: "ttf") {
                var error: Unmanaged<CFError>?
                let success = CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)
                if !success {
                    print("Failed to register \(fontName): \(error?.takeRetainedValue() ?? "unknown error" as! CFError)")
                } else {
                    print("Successfully registered \(fontName)")
                }
            } else {
                print("Could not find \(fontName)")
            }
        }

        // List all available fonts
        print("\nAvailable fonts containing 'Writer':")
        let families = NSFontManager.shared.availableFontFamilies
        for family in families where family.contains("Writer") {
            print("  - \(family)")
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
        .windowToolbarStyle(.unified(showsTitle: false))
        .commandsRemoved()

        Settings {
            SettingsView(discordService: discordService)
        }
    }
}
