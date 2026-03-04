import SwiftUI

struct InputAreaView: View {
    @Binding var text: String
    let isEnabled: Bool
    var showBorder: Bool = true
    let onSend: () -> Void
    let onAccessoryTap: () -> Void

    private let buttonSize: CGFloat = 43
    private let singleLineThreshold: CGFloat = 50
    private let expandedCornerRadius: CGFloat = 22

    @State private var fieldHeight: CGFloat = 0
    @FocusState private var isFieldFocused: Bool

    private var isMultiline: Bool {
        fieldHeight > singleLineThreshold
    }

    private var cornerRadius: CGFloat {
        isMultiline ? expandedCornerRadius : max(fieldHeight / 2, 22)
    }

    private var outerCornerRadius: CGFloat {
        (cornerRadius + 8).clamped(to: 22...40)
    }

    var body: some View {
        Group {
            if #available(iOS 26, *) {
                glassInputBar
            } else {
                materialInputBar
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
        .animation(.easeOut(duration: 0.22), value: isFieldFocused)
        .animation(.smooth(duration: 0.2), value: isMultiline)
        .opacity(isEnabled ? 1.0 : 0.5)
    }

    // MARK: - iOS 26+ (Liquid Glass)

    @available(iOS 26, *)
    private var glassInputBar: some View {
        GlassEffectContainer(spacing: 8) {
            HStack(alignment: .bottom, spacing: 8) {
                textFieldArea
                    .overlay { highlightBorder }
                    .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))

                glassTrailingButton
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
        }
    }

    @available(iOS 26, *)
    private var glassTrailingButton: some View {
        Button {
            if !text.isEmpty { onSend() } else { onAccessoryTap() }
        } label: {
            Image(systemName: text.isEmpty ? "mic" : "arrow.up")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: buttonSize, height: buttonSize)
        }
        .glassEffect(.regular.tint(.accentColor).interactive(), in: .circle)
        .disabled(!isEnabled)
        .accessibilityLabel(text.isEmpty ? "Record Voice Message" : "Send Message")
    }

    // MARK: - iOS 15+ Fallback (ultraThinMaterial)

    private var materialInputBar: some View {
        HStack(alignment: .bottom, spacing: 8) {
            textFieldArea
                .overlay { highlightBorder }
                .background(.regularMaterial, in: .rect(cornerRadius: cornerRadius))

            materialTrailingButton
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: outerCornerRadius))
    }

    private var materialTrailingButton: some View {
        Button {
            if !text.isEmpty { onSend() } else { onAccessoryTap() }
        } label: {
            Image(systemName: text.isEmpty ? "mic" : "arrow.up")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: buttonSize, height: buttonSize)
        }
        .background(Color.accentColor, in: .circle)
        .disabled(!isEnabled)
        .accessibilityLabel(text.isEmpty ? "Record Voice Message" : "Send Message")
    }

    // MARK: - Shared subviews

    private var textFieldArea: some View {
        TextField(isEnabled ? "Improve with Maieutic" : "Model Unavailable...", text: $text, axis: .vertical)
            .lineLimit(isFieldFocused ? 6 : 1)
            .focused($isFieldFocused)
            .font(.system(.body, design: .rounded))
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .disabled(!isEnabled)
            .accessibilityLabel("Message input field")
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.height
            } action: { newHeight in
                fieldHeight = newHeight
            }
    }

    private var highlightBorder: some View {
        RotatingGradientBorder(cornerRadius: cornerRadius)
            .opacity(!isFieldFocused && text.isEmpty && showBorder ? 1 : 0)
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
