import SwiftUI

struct ChatEmptyState: View {
    @Binding var inputText: String

    var body: some View {
        VStack(spacing: 20) {
            Text("Let's improve together.\nWhat are you searching for?")
                .font(.title3.weight(.medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 10) {
                promptCapsule("Explain quantum computing")
                HStack(spacing: 10) {
                    promptCapsule("Write a workout plan")
                    promptCapsule("Debug my code")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 40)
    }

    private func promptCapsule(_ text: String) -> some View {
        Button {
            inputText = text
        } label: {
            Text(text)
                .font(.caption).bold()
                .foregroundStyle(.secondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .glassEffect(.regular, in: Capsule())
        }
    }
}
