import SwiftUI

struct InputBar: View {
    @Binding var text: String
    let isEnabled: Bool
    var showBorder: Bool = true
    let onSend: () -> Void

    private let buttonSize: CGFloat = 46
    private let singleLineThreshold: CGFloat = 50
    private let expandedCornerRadius: CGFloat = 22

    @State private var fieldHeight: CGFloat = 0
    @FocusState private var isFieldFocused: Bool

    private var isMultiline: Bool { fieldHeight > singleLineThreshold }
    private var cornerRadius: CGFloat { isMultiline ? expandedCornerRadius : max(fieldHeight / 2, 22) }
    private var canSend: Bool { !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var body: some View {
        Group {
            if #available(iOS 26, *) {
                glassInputBar
            } else {
                materialInputBar
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .animation(.easeOut(duration: 0.22), value: isFieldFocused)
        .animation(.smooth(duration: 0.2), value: isMultiline)
        .animation(.smooth(duration: 0.2), value: canSend)
        .opacity(isEnabled ? 1.0 : 0.5)
    }

    // MARK: - Glass (iOS 26+)

    @available(iOS 26, *)
    private var glassInputBar: some View {
        GlassEffectContainer(spacing: 8) {
            HStack(alignment: .bottom, spacing: 8) {
                textField
                    .overlay { highlightBorder }
                    .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))

                if canSend {
                    glassSendButton
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
        }
    }

    @available(iOS 26, *)
    private var glassSendButton: some View {
        Button(action: onSend) {
            Image(systemName: "arrow.up")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: buttonSize, height: buttonSize)
        }
        .glassEffect(.regular.tint(.accentColor).interactive(), in: .circle)
        .disabled(!isEnabled)
    }

    // MARK: - Material (fallback)

    private var materialInputBar: some View {
        HStack(alignment: .bottom, spacing: 8) {
            textField
                .overlay { highlightBorder }
                .background(.regularMaterial, in: .rect(cornerRadius: cornerRadius))

            if canSend {
                materialSendButton
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: max(cornerRadius + 8, 22) as CGFloat))
    }

    private var materialSendButton: some View {
        Button(action: onSend) {
            Image(systemName: "arrow.up")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: buttonSize, height: buttonSize)
        }
        .background(Color.accentColor, in: .circle)
        .disabled(!isEnabled)
    }

    // MARK: - Shared

    private var textField: some View {
        TextField(isEnabled ? "Improve with Maieutic" : "Model Unavailable...", text: $text, axis: .vertical)
            .lineLimit(isFieldFocused ? 6 : 1)
            .focused($isFieldFocused)
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .disabled(!isEnabled)
            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { fieldHeight = $0 }
            .onSubmit { if canSend { onSend() } }
    }

    private var highlightBorder: some View {
        RotatingGradientBorder(cornerRadius: cornerRadius)
            .opacity(!isFieldFocused && text.isEmpty && showBorder ? 1 : 0)
    }
}
