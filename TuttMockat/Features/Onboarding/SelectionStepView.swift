import SwiftUI

struct SelectionStepView: View {
    let icon: String
    let title: String
    var description: String? = nil
    let options: [String]
    @Binding var selection: String

    var body: some View {
        ScrollView {
            headerSection
            optionsList
        }
        .scrollIndicators(.hidden)
    }

    private var headerSection: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(Color.accentColor)
                .padding(.top, 32)

            VStack(spacing: 8) {
                Text(title)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)

                if let description {
                    Text(description)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private var optionsList: some View {
        VStack(spacing: 8) {
            ForEach(options, id: \.self) { option in
                OptionRow(option: option, isSelected: selection == option) {
                    selection = option
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 28)
        .padding(.bottom, 40)
    }
}

private struct OptionRow: View {
    let option: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) { action() }
        }) {
            HStack {
                Text(option)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? Color.accentColor : Color.gray.opacity(0.4))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular, in: .rect(cornerRadius: 14))
    }
}
