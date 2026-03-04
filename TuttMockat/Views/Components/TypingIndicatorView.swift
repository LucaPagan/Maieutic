import SwiftUI

struct TypingIndicatorView: View {
    @State private var anim = false
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundColor(.teal)
                    .opacity(anim ? 1 : 0.3)
                    .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.2), value: anim)
            }
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
        .onAppear { anim = true }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .accessibilityLabel("Architect is typing")
    }
}
