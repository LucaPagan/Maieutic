import SwiftUI

struct MessageBubble: View {
    let message: Message

    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 48) }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                if message.isUser {
                    Text(message.text)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .glassEffect(
                            .clear.tint(Color.accentColor),
                            in: UnevenRoundedRectangle(
                                topLeadingRadius: 20,
                                bottomLeadingRadius: 20,
                                bottomTrailingRadius: 4,
                                topTrailingRadius: 20,
                                style: .continuous
                            )
                        )
                } else {
                    AIMessageView(text: message.text)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(message.isUser ? "You said: \(message.text)" : "Maieutic said: \(message.text)")

            if !message.isUser { Spacer(minLength: 48) }
        }
    }
}

// MARK: - AI Message Renderer

private struct AIMessageView: View {
    let text: String

    private enum Segment {
        case prose(String)
        case heading(String)
        case code(String, language: String)
    }

    private var segments: [Segment] {
        var result: [Segment] = []
        var remaining = text

        while !remaining.isEmpty {
            if let openRange = remaining.range(of: "```") {
                let before = String(remaining[remaining.startIndex..<openRange.lowerBound])
                result.append(contentsOf: parseProseAndHeadings(before))

                let afterOpen = remaining[openRange.upperBound...]
                var language = ""
                var codeStart = afterOpen.startIndex
                if let newline = afterOpen.firstIndex(of: "\n") {
                    language = String(afterOpen[afterOpen.startIndex..<newline])
                        .trimmingCharacters(in: .whitespaces)
                    codeStart = afterOpen.index(after: newline)
                }
                let afterLanguage = String(afterOpen[codeStart...])

                if let closeRange = afterLanguage.range(of: "```") {
                    let code = String(afterLanguage[afterLanguage.startIndex..<closeRange.lowerBound])
                    result.append(.code(code.trimmingCharacters(in: .newlines), language: language))
                    remaining = String(afterLanguage[closeRange.upperBound...])
                        .trimmingCharacters(in: .newlines)
                } else {
                    result.append(contentsOf: parseProseAndHeadings(afterLanguage))
                    remaining = ""
                }
            } else {
                result.append(contentsOf: parseProseAndHeadings(remaining))
                remaining = ""
            }
        }
        return result
    }

    private func parseProseAndHeadings(_ raw: String) -> [Segment] {
        guard !raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }
        var result: [Segment] = []
        var proseAccumulator = ""

        for line in raw.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            // Match heading: inizia con 1-3 # seguiti da spazio
            if let match = trimmed.range(of: "^#{1,3}\\s+", options: .regularExpression) {
                // Flush prose
                let prose = proseAccumulator.trimmingCharacters(in: .whitespacesAndNewlines)
                if !prose.isEmpty {
                    result.append(.prose(prose))
                    proseAccumulator = ""
                }
                let headingText = String(trimmed[match.upperBound...])
                    .trimmingCharacters(in: .whitespaces)
                if !headingText.isEmpty {
                    result.append(.heading(headingText))
                }
            } else {
                proseAccumulator += line + "\n"
            }
        }

        let prose = proseAccumulator.trimmingCharacters(in: .whitespacesAndNewlines)
        if !prose.isEmpty { result.append(.prose(prose)) }
        return result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(segments.enumerated()), id: \.offset) { _, segment in
                switch segment {
                case .prose(let text):
                    if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(markdownText(text))
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                case .heading(let title):
                    // Testo puro, nessun markdown processing — foregroundStyle garantito
                    Text(title)
                        .font(.system(.subheadline, design: .rounded).bold())
                        .foregroundStyle(Color(red: 0.43, green: 0.63, blue: 0.53))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 4)
                case .code(let code, let language):
                    CodeBlockView(code: code, language: language)
                }
            }
        }
    }

    private func markdownText(_ raw: String) -> AttributedString {
        (try? AttributedString(
            markdown: raw,
            options: .init(
                allowsExtendedAttributes: false, // Fix: true causava override del foregroundStyle
                interpretedSyntax: .inlineOnlyPreservingWhitespace
            )
        )) ?? AttributedString(raw)
    }
}
// MARK: - Code Block

private struct CodeBlockView: View {
    let code: String
    let language: String
    @State private var copied = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header bar
            HStack {
                Text(language.isEmpty ? "code" : language.lowercased())
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    UIPasteboard.general.string = code
                    withAnimation { copied = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation { copied = false }
                    }
                } label: {
                    Label(copied ? "Copied" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc")
                        .font(.caption.bold())
                        .foregroundStyle(copied ? .green : .secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(colorScheme == .dark ? Color(white: 0.18) : Color(white: 0.88))

            Divider()

            // Code content
            ScrollView(.horizontal, showsIndicators: false) {
                Text(code)
                    .font(.system(.footnote, design: .monospaced))
                    .foregroundStyle(colorScheme == .dark ? Color(white: 0.9) : Color(white: 0.1))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(colorScheme == .dark ? Color(white: 0.13) : Color(white: 0.93))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }
}
