import SwiftUI

/// A view that parses message text and renders code blocks and headers with proper formatting.
/// Supports triple-backtick fenced code blocks (``` ... ```), inline code (`...`), and Markdown headers (#).
struct FormattedMessageView: View {
    let text: String
    let isUser: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(parseBlocks().enumerated()), id: \.offset) { _, block in
                switch block {
                case .header(let level, let content):
                    renderSemanticText(content)
                        .font(headerFont(for: level))
                        .foregroundColor(isUser ? .white : .primary)
                        .padding(.top, level == 1 ? 8 : 4)
                        .padding(.bottom, 2)
                    
                case .text(let content):
                    renderSemanticText(content)
                        .font(.system(.body, design: .rounded))
                        .lineSpacing(4)
                        .foregroundColor(isUser ? .white : .primary)
                    
                case .code(let language, let content):
                    VStack(alignment: .leading, spacing: 0) {
                        // Language badge header
                        if !language.isEmpty {
                            HStack {
                                Text(language.uppercased())
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button {
                                    UIPasteboard.general.string = content
                                } label: {
                                    Image(systemName: "doc.on.doc")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(codeHeaderColor)
                        }
                        
                        // Code content
                        ScrollView(.horizontal, showsIndicators: false) {
                            Text(content)
                                .font(.system(size: 13, weight: .regular, design: .monospaced))
                                .foregroundColor(codeTextColor)
                                .lineSpacing(3)
                                .padding(12)
                        }
                    }
                    .background(codeBackgroundColor)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(codeBorderColor, lineWidth: 1)
                    )
                }
            }
        }
    }
    
    // MARK: - Typography
    
    private func headerFont(for level: Int) -> Font {
        switch level {
        case 1: return .system(.title2, design: .rounded).bold()
        case 2: return .system(.title3, design: .rounded).bold()
        case 3: return .system(.headline, design: .rounded).bold()
        default: return .system(.subheadline, design: .rounded).bold()
        }
    }
    
    // MARK: - Code Block Colors
    
    private var codeBackgroundColor: Color {
        isUser ? Color.white.opacity(0.12) : Color(uiColor: .tertiarySystemGroupedBackground)
    }
    
    private var codeHeaderColor: Color {
        isUser ? Color.white.opacity(0.08) : Color(uiColor: .quaternarySystemFill)
    }
    
    private var codeTextColor: Color {
        isUser ? Color.white.opacity(0.95) : Color(uiColor: .label)
    }
    
    private var codeBorderColor: Color {
        isUser ? Color.white.opacity(0.15) : Color(uiColor: .separator)
    }
    
    // MARK: - Parsing Engine
    
    /// Content block type — either plain text, a fenced code block, or a header.
    private enum ContentBlock {
        case text(String)
        case code(language: String, content: String)
        case header(level: Int, text: String)
    }
    
    /// Parses the message text into an array of text, code, and header blocks.
    private func parseBlocks() -> [ContentBlock] {
        var blocks: [ContentBlock] = []
        let lines = text.components(separatedBy: "\n")
        
        var currentTextLines: [String] = []
        var currentCodeLines: [String] = []
        var insideCodeBlock = false
        var codeLanguage = ""
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.hasPrefix("```") && !insideCodeBlock {
                // Flush accumulated text
                flushText(&currentTextLines, into: &blocks)
                
                // Start code block
                codeLanguage = String(trimmed.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                insideCodeBlock = true
                currentCodeLines.removeAll()
                
            } else if trimmed.hasPrefix("```") && insideCodeBlock {
                // End code block
                let codeContent = currentCodeLines.joined(separator: "\n")
                blocks.append(.code(language: codeLanguage, content: codeContent))
                currentCodeLines.removeAll()
                insideCodeBlock = false
                codeLanguage = ""
                
            } else if insideCodeBlock {
                currentCodeLines.append(line)
            } else if trimmed.hasPrefix("#") && !insideCodeBlock {
                // Flush accumulated text
                flushText(&currentTextLines, into: &blocks)
                
                // Parse header
                let level = trimmed.prefix(while: { $0 == "#" }).count
                let headerText = trimmed.drop(while: { $0 == "#" || $0 == " " })
                blocks.append(.header(level: level, text: String(headerText)))
            } else {
                currentTextLines.append(line)
            }
        }
        
        // Flush remaining content
        if insideCodeBlock {
            let codeContent = currentCodeLines.joined(separator: "\n")
            if !codeContent.isEmpty {
                blocks.append(.code(language: codeLanguage, content: codeContent))
            }
        }
        
        flushText(&currentTextLines, into: &blocks)
        
        // If no blocks were produced (shouldn't happen), fallback to plain text
        if blocks.isEmpty && !text.isEmpty {
            blocks.append(.text(text))
        }
        
        return blocks
    }
    
    private func flushText(_ lines: inout [String], into blocks: inout [ContentBlock]) {
        let textContent = lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        if !textContent.isEmpty {
            blocks.append(.text(textContent))
        }
        lines.removeAll()
    }
    
    // MARK: - Semantic Text Renderer
    
    private func renderSemanticText(_ content: String) -> Text {
        var result = Text("")
        var remaining = content
        
        while !remaining.isEmpty {
            let objStart = remaining.range(of: "<obj>")
            let dedStart = remaining.range(of: "<ded>")
            
            if let oStart = objStart, let dStart = dedStart {
                if oStart.lowerBound < dStart.lowerBound {
                    remaining = processTag(remaining, startTag: "<obj>", endTag: "</obj>", color: .green, result: &result)
                } else {
                    remaining = processTag(remaining, startTag: "<ded>", endTag: "</ded>", color: .yellow, result: &result)
                }
            } else if objStart != nil {
                remaining = processTag(remaining, startTag: "<obj>", endTag: "</obj>", color: .green, result: &result)
            } else if dedStart != nil {
                remaining = processTag(remaining, startTag: "<ded>", endTag: "</ded>", color: .yellow, result: &result)
            } else {
                result = result + Text(LocalizedStringKey(remaining))
                break
            }
        }
        return result
    }
    
    private func processTag(_ remaining: String, startTag: String, endTag: String, color: Color, result: inout Text) -> String {
        guard let start = remaining.range(of: startTag),
              let end = remaining.range(of: endTag, range: start.upperBound..<remaining.endIndex) else {
            result = result + Text(LocalizedStringKey(remaining))
            return ""
        }
        
        let before = String(remaining[..<start.lowerBound])
        let inside = String(remaining[start.upperBound..<end.lowerBound])
        
        result = result + Text(LocalizedStringKey(before))
        result = result + Text(LocalizedStringKey(inside))
            .foregroundColor(color)
            .bold()
        
        return String(remaining[end.upperBound...])
    }
}
