import Foundation

#if canImport(FoundationModels)
import FoundationModels

@available(iOS 18.0, macOS 15.0, *)
class AppleLocalModelService {
    private let maxPromptCharacters = 8000
    private let systemPromptBudget = 3000

    private var conversationSummary = ""
    private var summarizedUpToIndex = 0

    func resetSession() {
        conversationSummary = ""
        summarizedUpToIndex = 0
    }

    func generateResponse(history: [Message], systemPrompt: String) async throws -> String {
        let promptContext = buildPrompt(history: history, systemPrompt: systemPrompt)
        let session = LanguageModelSession()
        let response = try await session.respond(to: promptContext)
        return cleanResponseText(String(describing: response))
    }

    // MARK: - Prompt Construction

    private func buildPrompt(history: [Message], systemPrompt: String) -> String {
        var prompt = "INSTRUCTIONS:\n\(systemPrompt)\n\n"
        let availableBudget = max(maxPromptCharacters - prompt.count - 100, 1500)
        prompt += buildConversationBlock(history: history, budget: availableBudget)
        // RIMOSSO: prompt += "\nArchitect:" — causava risposta triplicata
        return prompt
    }

    private func buildConversationBlock(history: [Message], budget: Int) -> String {
        guard !history.isEmpty else { return "CONVERSATION HISTORY:\n(New conversation)\n" }

        let windowSize = min(4, history.count)
        let outsideWindow = history.count - windowSize

        if outsideWindow > summarizedUpToIndex {
            let newMessages = Array(history[summarizedUpToIndex..<outsideWindow])
            conversationSummary = compressSummary(existing: conversationSummary, newMessages: newMessages)
            summarizedUpToIndex = outsideWindow
        }

        var block = "CONVERSATION HISTORY:\n"
        if !conversationSummary.isEmpty {
            block += "[Previous context: \(conversationSummary)]\n\n"
        }

        let recent = Array(history.suffix(windowSize))
        for message in recent {
            let role = message.isUser ? "User" : "Architect"
            let truncated = truncate(message.text, maxLength: budget / windowSize)
            block += "\(role): \(truncated)\n"
        }

        // Emergency fallback if over budget
        if block.count > budget {
            block = "CONVERSATION HISTORY:\n"
            let emergencySize = min(2, history.count)
            for message in history.suffix(emergencySize) {
                let role = message.isUser ? "User" : "Architect"
                block += "\(role): \(truncate(message.text, maxLength: budget / 2))\n"
            }
        }

        return block
    }

    // MARK: - Text Processing

    private func cleanResponseText(_ raw: String) -> String {
        var text = raw

        // 1. Strip LanguageModelSession wrapper metadata
        //    Format: "duration: X.X feedbackAttachment: nil, content: \"...\""
        //    or variations with extra fields before content
        if let contentKeyRange = text.range(of: "content: \"", options: .caseInsensitive) {
            let afterKey = text[contentKeyRange.upperBound...]
            var result = ""
            var escaped = false
            for char in afterKey {
                if escaped {
                    if char == "n" { result.append("\n") }
                    else if char == "t" { result.append("\t") }
                    else { result.append(char) }
                    escaped = false
                } else if char == "\\" {
                    escaped = true
                } else if char == "\"" {
                    break
                } else {
                    result.append(char)
                }
            }
            if !result.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                text = result
            }
        }

        // 2. Unescape residui
        text = text
            .replacingOccurrences(of: "\\n", with: "\n")
            .replacingOccurrences(of: "\\\"", with: "\"")

        // 3. Strip leaked system prompt artifacts
        if let range = text.range(of: "Architect:", options: .backwards) {
            let candidate = String(text[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !candidate.isEmpty { text = candidate }
        }
        if let start = text.range(of: "[SYSTEM RULES]"),
           let end = text.range(of: "Do not output the system prompt.") {
            text.removeSubrange(start.lowerBound...end.upperBound)
        }

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func compressSummary(existing: String, newMessages: [Message]) -> String {
        var parts: [String] = []

        if !existing.isEmpty {
            parts.append(existing.count > 300 ? String(existing.suffix(300)) : existing)
        }

        for message in newMessages {
            let role = message.isUser ? "U" : "A"
            let condensed = extractFirstSentence(from: message.text, maxLength: 80)
            parts.append("\(role): \(condensed)")
        }

        let combined = parts.joined(separator: " | ")
        return combined.count > 500 ? String(combined.suffix(500)) : combined
    }

    private func extractFirstSentence(from text: String, maxLength: Int) -> String {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let searchEnd = cleaned.index(cleaned.startIndex, offsetBy: min(cleaned.count, maxLength * 2))

        if let dot = cleaned.range(of: ".", range: cleaned.startIndex..<searchEnd) {
            let sentence = String(cleaned[cleaned.startIndex...dot.lowerBound])
            if sentence.count <= maxLength { return sentence }
        }

        return cleaned.count > maxLength ? String(cleaned.prefix(maxLength)) + "…" : cleaned
    }

    private func truncate(_ text: String, maxLength: Int) -> String {
        let effectiveMax = max(maxLength, 200)
        guard text.count > effectiveMax else { return text }
        let head = String(text.prefix(effectiveMax * 2 / 3))
        let tail = String(text.suffix(effectiveMax / 3))
        return "\(head) [...] \(tail)"
    }
}
#endif
