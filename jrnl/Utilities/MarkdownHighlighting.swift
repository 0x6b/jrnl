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
        let customBoldFont: NSFont = {
            let fontManager = NSFontManager.shared
            var boldFont = fontManager.convert(font, toHaveTrait: .boldFontMask)
            boldFont = fontManager.convert(boldFont, toHaveTrait: .expandedFontMask)
            return boldFont
        }()

        let customBoldOnlyFont: NSFont = {
            return NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask)
        }()

        let customItalicFont: NSFont = {
            return NSFontManager.shared.convert(font, toHaveTrait: .italicFontMask)
        }()

        let customBoldItalicFont: NSFont = {
            let fontManager = NSFontManager.shared
            let boldFont = fontManager.convert(font, toHaveTrait: .boldFontMask)
            return fontManager.convert(boldFont, toHaveTrait: .italicFontMask)
        }()

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

        let secondaryBackground = NSColor.windowBackgroundColor
        let lighterColor = NSColor.lightGray
        let textColor = NSColor.labelColor

        return [
            baseFontRule,
            HighlightRule(pattern: inlineCodeRegex, formattingRule: TextFormattingRule(key: .font, value: font)),
            HighlightRule(pattern: codeBlockRegex, formattingRule: TextFormattingRule(key: .font, value: font)),
            HighlightRule(pattern: headingRegex, formattingRules: [
                TextFormattingRule(key: .font, value: customBoldFont),
                TextFormattingRule(key: .kern, value: 0.5)
            ]),
            HighlightRule(pattern: linkOrImageRegex, formattingRule: TextFormattingRule(key: .underlineStyle, value: NSUnderlineStyle.single.rawValue)),
            HighlightRule(pattern: linkOrImageTagRegex, formattingRule: TextFormattingRule(key: .underlineStyle, value: NSUnderlineStyle.single.rawValue)),
            HighlightRule(pattern: boldRegex, formattingRule: TextFormattingRule(key: .font, value: customBoldOnlyFont)),
            HighlightRule(pattern: asteriskEmphasisRegex, formattingRule: TextFormattingRule(key: .font, value: customItalicFont)),
            HighlightRule(pattern: underscoreEmphasisRegex, formattingRule: TextFormattingRule(key: .font, value: customItalicFont)),
            HighlightRule(pattern: boldEmphasisAsteriskRegex, formattingRule: TextFormattingRule(key: .font, value: customBoldItalicFont)),
            HighlightRule(pattern: blockquoteRegex, formattingRule: TextFormattingRule(key: .backgroundColor, value: secondaryBackground)),
            HighlightRule(pattern: horizontalRuleRegex, formattingRule: TextFormattingRule(key: .foregroundColor, value: lighterColor)),
            HighlightRule(pattern: unorderedListRegex, formattingRule: TextFormattingRule(key: .foregroundColor, value: lighterColor)),
            HighlightRule(pattern: orderedListRegex, formattingRule: TextFormattingRule(key: .foregroundColor, value: lighterColor)),
            HighlightRule(pattern: strikethroughRegex, formattingRules: [
                TextFormattingRule(key: .strikethroughStyle, value: NSUnderlineStyle.single.rawValue),
                TextFormattingRule(key: .strikethroughColor, value: textColor)
            ]),
            HighlightRule(pattern: tagRegex, formattingRule: TextFormattingRule(key: .foregroundColor, value: lighterColor)),
            HighlightRule(pattern: footnoteRegex, formattingRule: TextFormattingRule(key: .foregroundColor, value: lighterColor)),
            HighlightRule(pattern: htmlRegex, formattingRules: [
                TextFormattingRule(key: .font, value: font),
                TextFormattingRule(key: .foregroundColor, value: lighterColor)
            ])
        ]
    }
}
