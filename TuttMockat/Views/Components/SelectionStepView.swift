import SwiftUI

struct SelectionStepView: View {
    let title: String
    var description: String? = nil
    let options: [String]
    @Binding var selection: String
    let onSelect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.leading)
                    .accessibilityAddTraits(.isHeader)
                
                if let description = description {
                    Text(description)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selection = option
                            }
                            // Small delay to let the user see the checkmark animation before transitioning
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                onSelect()
                            }
                        }) {
                            HStack {
                                Text(option)
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(selection == option ? .semibold : .regular)
                                    .foregroundColor(selection == option ? .white : .primary)
                                Spacer()
                                if selection == option {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .padding()
                            .background {
                                if selection == option {
                                    Color.accentColor
                                } else {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.regularMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                                        )
                                }
                            }
                            .cornerRadius(16)
                            .shadow(color: selection == option ? Color.accentColor.opacity(0.3) : .black.opacity(0.04), radius: selection == option ? 8 : 4, y: selection == option ? 4 : 2)
                        }
                        .buttonStyle(ModernSelectionButtonStyle())
                        .accessibilityLabel(option)
                        .accessibilityAddTraits(selection == option ? [.isSelected] : [])
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
        }
    }
}

// MARK: - Modern Button Style

struct ModernSelectionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
