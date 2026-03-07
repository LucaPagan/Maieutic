import Foundation

struct ParsedResponse {
    let score: Int?
    let intent: String?
    let sentiment: String?
    let cleanText: String
}

enum ResponseParser {
    // Parses AI response metadata: [S:{score}|I:{intent}|F:{sentiment}]
    // Falls back to legacy format: [SCORE:], [INTENT:], [SENTIMENT:]
    static func parse(_ response: String) -> ParsedResponse {
        var score: Int?
        var intent: String?
        var sentiment: String?
        
        // Pre-clean: strip LanguageModelSession metadata prefix if still present
        // e.g. "duration: 7.76 feedbackAttachment: nil, content: \"[S:80|...]...\""
        var text = response
        if let contentRange = text.range(of: "content: \"", options: .caseInsensitive) {
            let after = text[contentRange.upperBound...]
            if let endQuote = after.firstIndex(of: "\"") {
                text = String(after[after.startIndex..<endQuote])
                    .replacingOccurrences(of: "\\n", with: "\n")
            }
        }

        // Compact format [S:XX|I:INTENT|F:SENTIMENT]
        if let match = text.range(of: #"(?m)^\[S:([a-zA-Z0-9]+)\|I:([a-zA-Z0-9]+)\|F:([a-zA-Z0-9_]+)\]"#, options: .regularExpression) {
            let meta = String(text[match])
            score = extractValue(from: meta, key: "S:").flatMap(Int.init)
            intent = extractValue(from: meta, key: "I:")
            sentiment = extractValue(from: meta, key: "F:")
            text.removeSubrange(match)
        } else {
            // Legacy format fallback
            score = extractLegacyTag(&text, pattern: #"(?m)^\[SCORE:\s*(\d+)\]"#, prefix: "[SCORE:", suffix: "]").flatMap(Int.init)
            intent = extractLegacyTag(&text, pattern: #"(?m)^\[INTENT:\s*([A-Za-z]+)\]"#, prefix: "[INTENT:", suffix: "]")
            sentiment = extractLegacyTag(&text, pattern: #"(?m)^\[SENTIMENT:\s*([A-Za-z]+)\]"#, prefix: "[SENTIMENT:", suffix: "]")
        }

        return ParsedResponse(
            score: score,
            intent: intent,
            sentiment: sentiment,
            cleanText: text.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    private static func extractValue(from meta: String, key: String) -> String? {
        let pattern = "\(key)([a-zA-Z0-9]+)"
        guard let range = meta.range(of: pattern, options: .regularExpression) else { return nil }
        return meta[range].replacingOccurrences(of: key, with: "")
    }

    private static func extractLegacyTag(_ text: inout String, pattern: String, prefix: String, suffix: String) -> String? {
        guard let match = text.range(of: pattern, options: .regularExpression) else { return nil }
        let value = text[match]
            .replacingOccurrences(of: prefix, with: "")
            .replacingOccurrences(of: suffix, with: "")
            .trimmingCharacters(in: .whitespaces)
        text.removeSubrange(match)
        return value
    }
}
