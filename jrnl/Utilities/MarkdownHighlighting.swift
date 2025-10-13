//
//  MarkdownHighlighting.swift
//  jrnl
//
//  Created by kaoru on 2025/10/13.
//

import AppKit
import HighlightedTextEditor

struct MarkdownHighlighting {
    static func rules(for font: NSFont) -> [HighlightRule] {
        // Create font variants explicitly for iA Writer Duo S
        let boldFont = NSFont(name: "iAWriterDuoS-Bold", size: font.pointSize) ?? font
        let italicFont = NSFont(name: "iAWriterDuoS-Italic", size: font.pointSize) ?? font
        let boldItalicFont = NSFont(name: "iAWriterDuoS-BoldItalic", size: font.pointSize) ?? font

        // Base font for all text
        let baseFontRule = HighlightRule(pattern: .all, formattingRule: TextFormattingRule(key: .font, value: font))

        // Custom markdown rules with equal font sizes
        let inlineCodeRegex = try! NSRegularExpression(pattern: "`[^`]*`", options: [])
        let codeBlockRegex = try! NSRegularExpression(pattern: "(`){3}((?!\\1).)+\\1{3}", options: [.dotMatchesLineSeparators])
        let headingRegex = try! NSRegularExpression(pattern: "^#{1,6}\\s.*$", options: [.anchorsMatchLines])
        let linkOrImageRegex = try! NSRegularExpression(pattern: "!?\\[([^\\[\\]]*)\\]\\((.*?)\\)", options: [])
        let linkOrImageTagRegex = try! NSRegularExpression(pattern: "!?\\[([^\\[\\]]*)\\]\\[(.*?)\\]", options: [])
        let boldRegex = try! NSRegularExpression(pattern: "((\\*|_){2})((?!\\1).)+\\1", options: [])
        let underscoreEmphasisRegex = try! NSRegularExpression(pattern: "(?<!_)_[^_]+_(?!\\*)", options: [])
        let asteriskEmphasisRegex = try! NSRegularExpression(pattern: "(?<!\\*)(\\*)((?!\\1).)+\\1(?!\\*)", options: [])
        let boldEmphasisAsteriskRegex = try! NSRegularExpression(pattern: "(\\*){3}((?!\\1).)+\\1{3}", options: [])
        let blockquoteRegex = try! NSRegularExpression(pattern: "^>.*", options: [.anchorsMatchLines])
        let horizontalRuleRegex = try! NSRegularExpression(pattern: "\n\n(-{3}|\\*{3})\n", options: [])
        let unorderedListRegex = try! NSRegularExpression(pattern: "^(\\-|\\*)\\s", options: [.anchorsMatchLines])
        let orderedListRegex = try! NSRegularExpression(pattern: "^\\d*\\.\\s", options: [.anchorsMatchLines])
        let strikethroughRegex = try! NSRegularExpression(pattern: "(~)((?!\\1).)+\\1", options: [])
        let tagRegex = try! NSRegularExpression(pattern: "^\\[([^\\[\\]]*)\\]:", options: [.anchorsMatchLines])
        let footnoteRegex = try! NSRegularExpression(pattern: "\\[\\^(.*?)\\]", options: [])
        let htmlRegex = try! NSRegularExpression(pattern: "<([A-Z][A-Z0-9]*)\\b[^>]*>(.*?)</\\1>", options: [.dotMatchesLineSeparators, .caseInsensitive])

        // Theme colors from papercolor-light
        let gray = NSColor(red: 0x6d/255.0, green: 0x6a/255.0, blue: 0x75/255.0, alpha: 1.0)
        let grayLight = NSColor(red: 0xb3/255.0, green: 0xb1/255.0, blue: 0xb8/255.0, alpha: 1.0)
        let yellowDark = NSColor(red: 0x92/255.0, green: 0x85/255.0, blue: 0x3e/255.0, alpha: 1.0)
        let greenShade = NSColor(red: 0x24/255.0, green: 0x75/255.0, blue: 0x47/255.0, alpha: 1.0)
        let blueTint = NSColor(red: 0x56/255.0, green: 0x8e/255.0, blue: 0xff/255.0, alpha: 1.0)
        let magentaShade = NSColor(red: 0xb3/255.0, green: 0x23/255.0, blue: 0x8c/255.0, alpha: 1.0)
        let orangeLighter = NSColor(red: 0xff/255.0, green: 0xd3/255.0, blue: 0xae/255.0, alpha: 1.0)
        let inkBright = NSColor(red: 0xf6/255.0, green: 0xf9/255.0, blue: 0xfc/255.0, alpha: 1.0)
        let redLightest = NSColor(red: 0xff/255.0, green: 0xdf/255.0, blue: 0xe6/255.0, alpha: 1.0)
        let greenLightest = NSColor(red: 0xda/255.0, green: 0xf4/255.0, blue: 0xe5/255.0, alpha: 1.0)
        let orangeLightest = NSColor(red: 0xff/255.0, green: 0xe8/255.0, blue: 0xd5/255.0, alpha: 1.0)

        let textColor = NSColor.labelColor

        return [
            baseFontRule,
            HighlightRule(pattern: inlineCodeRegex, formattingRules: [
                TextFormattingRule(key: .font, value: font),
                TextFormattingRule(key: .foregroundColor, value: yellowDark),
                TextFormattingRule(key: .backgroundColor, value: orangeLightest)
            ]),
            HighlightRule(pattern: codeBlockRegex, formattingRules: [
                TextFormattingRule(key: .font, value: font),
                TextFormattingRule(key: .foregroundColor, value: yellowDark),
                TextFormattingRule(key: .backgroundColor, value: orangeLightest)
            ]),
            HighlightRule(pattern: headingRegex, formattingRule: TextFormattingRule(key: .font, value: boldFont)),
            HighlightRule(pattern: linkOrImageRegex, formattingRules: [
                TextFormattingRule(key: .foregroundColor, value: blueTint),
                TextFormattingRule(key: .underlineStyle, value: NSUnderlineStyle.single.rawValue)
            ]),
            HighlightRule(pattern: linkOrImageTagRegex, formattingRules: [
                TextFormattingRule(key: .foregroundColor, value: blueTint),
                TextFormattingRule(key: .underlineStyle, value: NSUnderlineStyle.single.rawValue)
            ]),
            HighlightRule(pattern: boldRegex, formattingRule: TextFormattingRule(key: .font, value: boldFont)),
            HighlightRule(pattern: asteriskEmphasisRegex, formattingRule: TextFormattingRule(key: .font, value: italicFont)),
            HighlightRule(pattern: underscoreEmphasisRegex, formattingRule: TextFormattingRule(key: .font, value: italicFont)),
            HighlightRule(pattern: boldEmphasisAsteriskRegex, formattingRule: TextFormattingRule(key: .font, value: boldItalicFont)),
            HighlightRule(pattern: blockquoteRegex, formattingRules: [
                TextFormattingRule(key: .foregroundColor, value: yellowDark),
                TextFormattingRule(key: .backgroundColor, value: orangeLightest)
            ]),
            HighlightRule(pattern: horizontalRuleRegex, formattingRule: TextFormattingRule(key: .foregroundColor, value: grayLight)),
            HighlightRule(pattern: unorderedListRegex, formattingRule: TextFormattingRule(key: .foregroundColor, value: magentaShade)),
            HighlightRule(pattern: orderedListRegex, formattingRule: TextFormattingRule(key: .foregroundColor, value: magentaShade)),
            HighlightRule(pattern: strikethroughRegex, formattingRules: [
                TextFormattingRule(key: .strikethroughStyle, value: NSUnderlineStyle.single.rawValue),
                TextFormattingRule(key: .strikethroughColor, value: textColor)
            ]),
            HighlightRule(pattern: tagRegex, formattingRule: TextFormattingRule(key: .foregroundColor, value: grayLight)),
            HighlightRule(pattern: footnoteRegex, formattingRule: TextFormattingRule(key: .foregroundColor, value: grayLight)),
            HighlightRule(pattern: htmlRegex, formattingRules: [
                TextFormattingRule(key: .font, value: font),
                TextFormattingRule(key: .foregroundColor, value: grayLight)
            ])
        ]
    }
}
