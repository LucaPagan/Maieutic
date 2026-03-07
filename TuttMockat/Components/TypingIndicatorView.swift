import SwiftUI

struct TypingIndicatorView: View {
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundStyle(.tint)
                    .opacity(isAnimating ? 1 : 0.3)
                    .animation(
                        .easeInOut(duration: 0.5)
                            .repeatForever(autoreverses: true)  // Fix: autoreverses esplicito
                            .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .padding(12)
        .background(Color(uiColor: .tertiarySystemFill), in: Capsule())
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .accessibilityLabel("Generating response")
        .onAppear { isAnimating = true }
        .onDisappear { isAnimating = false }  // Fix: ferma animazione prima della rimozione
    }
}
