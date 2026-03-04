import Foundation

#if canImport(FoundationModels)
import FoundationModels

@available(iOS 18.0, macOS 15.0, *)
class AppleLocalModelService {
    
    // MARK: - Token Budget Configuration
    // Apple Intelligence on-device model has a limited context window (~4096 tokens).
    // We must budget tokens carefully between system prompt, history, and generation.
    // Rough estimates: 1 token ≈ 3.5 characters (for mixed Italian/English text).
    
    private let maxPromptCharacters: Int = 8000    // ~2300 tokens for the full prompt sent to the model
    private let systemPromptBudget: Int = 4500     // ~1300 tokens reserved for the system prompt (it's big, we protect it)
    private let generationHeadroom: Int = 2000     // ~570 tokens reserved for the model's response
    
    // History budget = maxPromptCharacters - systemPromptBudget - overhead
    private var historyBudget: Int {
        return maxPromptCharacters - systemPromptBudget - 200 // 200 chars formatting overhead
    }
    
    // MARK: - Summarization State
    /// Compact summary of older conversation messages that were evicted from the sliding window.
    /// This preserves context without consuming full token space.
    private var conversationSummary: String = ""
    
    /// Track how many messages have been summarized so we don't re-summarize.
    private var summarizedUpToIndex: Int = 0
    
    init() {
        print("Apple Foundation Model Engine Initialized.")
    }
    
    /// Resets the summary state (call when starting a new session).
    func resetSession() {
        conversationSummary = ""
        summarizedUpToIndex = 0
    }
    
    // MARK: - Public API
    
    func generateResponse(history: [Message], systemPrompt: String) async throws -> String {
        
        // Step 1: Build the optimized prompt within budget
        let promptContext = buildOptimizedPrompt(history: history, systemPrompt: systemPrompt)
        
        // Step 2: Create a FRESH session for each call.
        // This is critical: LanguageModelSession accumulates internal context across calls.
        // By creating a new session each time, we prevent the internal context from growing
        // and guarantee we only send exactly the tokens we control.
        let freshSession = LanguageModelSession()
        
        do {
            let response = try await freshSession.respond(to: promptContext)
            
            // Use the public String(describing:) API instead of Mirror reflection
            // to avoid private API usage detection during App Store review.
            let extractedText = String(describing: response)
            
            return extractedText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
        } catch {
            print("Foundation Model Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Prompt Construction Engine
    
    /// Builds the final prompt string, intelligently fitting history within the token budget.
    private func buildOptimizedPrompt(history: [Message], systemPrompt: String) -> String {
        
        // 1. System prompt is always included in full (it's essential)
        var prompt = "INSTRUCTIONS:\n\(systemPrompt)\n\n"
        
        // 2. Determine how many characters are left for conversation history
        let usedBySystem = prompt.count
        let availableForHistory = max(maxPromptCharacters - usedBySystem - 100, 1500) // at least 1500 chars for history
        
        // 3. Build conversation context using sliding window + summarization
        let conversationBlock = buildConversationBlock(history: history, budget: availableForHistory)
        
        prompt += conversationBlock
        prompt += "\nArchitect:"
        
        return prompt
    }
    
    /// Builds the conversation history block using a smart sliding window.
    /// - Recent messages are kept verbatim (they contain the active conversation thread).
    /// - Older messages are compressed into a running summary.
    /// - Individual messages are truncated if excessively long.
    private func buildConversationBlock(history: [Message], budget: Int) -> String {
        guard !history.isEmpty else { return "CONVERSATION HISTORY:\n(New conversation)\n" }
        
        // --- Phase 1: Identify which messages go in the "recent window" ---
        // Always try to include the last 4 messages (2 turns) verbatim.
        // If that doesn't fit, reduce to 2 messages (1 turn).
        let maxWindowSize = min(4, history.count)
        var windowSize = maxWindowSize
        
        // --- Phase 2: Compress messages outside the window into a summary ---
        let messagesOutsideWindow = history.count - windowSize
        if messagesOutsideWindow > summarizedUpToIndex {
            // There are new messages that need to be folded into the summary
            let newMessagesToSummarize = Array(history[summarizedUpToIndex..<messagesOutsideWindow])
            conversationSummary = compressSummary(existing: conversationSummary, newMessages: newMessagesToSummarize)
            summarizedUpToIndex = messagesOutsideWindow
        }
        
        // --- Phase 3: Build the block and check it fits ---
        var block = "CONVERSATION HISTORY:\n"
        
        if !conversationSummary.isEmpty {
            block += "[Previous context: \(conversationSummary)]\n\n"
        }
        
        // Build recent messages with per-message truncation
        let recentMessages = Array(history.suffix(windowSize))
        var recentBlock = ""
        for message in recentMessages {
            let role = message.isUser ? "User" : "Architect"
            let truncatedText = truncateMessage(message.text, maxLength: budget / windowSize)
            recentBlock += "\(role): \(truncatedText)\n"
        }
        
        block += recentBlock
        
        // --- Phase 4: If still over budget, aggressively trim ---
        if block.count > budget {
            // Drop the summary to save space
            block = "CONVERSATION HISTORY:\n"
            
            // Reduce window to just 2 messages (the very last exchange)
            windowSize = min(2, history.count)
            let emergencyMessages = Array(history.suffix(windowSize))
            for message in emergencyMessages {
                let role = message.isUser ? "User" : "Architect"
                let truncatedText = truncateMessage(message.text, maxLength: budget / 2)
                block += "\(role): \(truncatedText)\n"
            }
        }
        
        return block
    }
    
    // MARK: - Summarization
    
    /// Compresses older messages into a compact summary string.
    /// This is a local heuristic summarizer (no AI call needed) that extracts key topics.
    private func compressSummary(existing: String, newMessages: [Message]) -> String {
        var summaryParts: [String] = []
        
        if !existing.isEmpty {
            // Keep existing summary but cap it to avoid unbounded growth
            let cappedExisting = existing.count > 300 ? String(existing.suffix(300)) : existing
            summaryParts.append(cappedExisting)
        }
        
        // Extract key content from new messages
        for message in newMessages {
            let role = message.isUser ? "U" : "A"
            // Take the first sentence or first 80 chars, whichever is shorter
            let condensed = extractKeyContent(from: message.text, maxLength: 80)
            summaryParts.append("\(role): \(condensed)")
        }
        
        // Join and cap the total summary length
        var combined = summaryParts.joined(separator: " | ")
        if combined.count > 500 {
            combined = String(combined.suffix(500))
        }
        
        return combined
    }
    
    /// Extracts the most important part of a message for summarization.
    private func extractKeyContent(from text: String, maxLength: Int) -> String {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try to get the first sentence
        if let dotRange = cleaned.range(of: ".", range: cleaned.startIndex..<cleaned.index(cleaned.startIndex, offsetBy: min(cleaned.count, maxLength * 2))) {
            let firstSentence = String(cleaned[cleaned.startIndex...dotRange.lowerBound])
            if firstSentence.count <= maxLength {
                return firstSentence
            }
        }
        
        // Fallback: just truncate
        if cleaned.count > maxLength {
            return String(cleaned.prefix(maxLength)) + "…"
        }
        return cleaned
    }
    
    // MARK: - Message Truncation
    
    /// Truncates a single message text if it exceeds the allowed length.
    /// Preserves the beginning (the question/statement) and the end (the conclusion).
    private func truncateMessage(_ text: String, maxLength: Int) -> String {
        let effectiveMax = max(maxLength, 200) // always allow at least 200 chars
        guard text.count > effectiveMax else { return text }
        
        let headLength = effectiveMax * 2 / 3  // Keep 66% from start
        let tailLength = effectiveMax / 3        // Keep 33% from end
        
        let head = String(text.prefix(headLength))
        let tail = String(text.suffix(tailLength))
        
        return "\(head) [...] \(tail)"
    }
}
#endif
