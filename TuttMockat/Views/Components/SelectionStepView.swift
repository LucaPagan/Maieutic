import SwiftUI

struct SelectionStepView: View {
    let title: String
    let options: [String]
    @Binding var selection: String
    let onSelect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
                .padding(.bottom, 10)
                .accessibilityAddTraits(.isHeader)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            selection = option
                            onSelect()
                        }) {
                            HStack {
                                Text(option)
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(selection == option ? .white : .primary)
                                Spacer()
                                if selection == option {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(selection == option ? Color.teal : Color(uiColor: .secondarySystemGroupedBackground))
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                        }
                        .accessibilityLabel(option)
                        .accessibilityAddTraits(selection == option ? [.isSelected] : [])
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}
