import SwiftUI

struct SettingsPickerRow: View {
    let icon: String
    let label: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: 24, alignment: .center)

            Text(label)
                .font(.body)

            Spacer()

            Menu {
                ForEach(options, id: \.self) { option in
                    Button {
                        selection = option
                    } label: {
                        if option == selection {
                            Label(option, systemImage: "checkmark")
                        } else {
                            Text(option)
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(selection)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .tint(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
