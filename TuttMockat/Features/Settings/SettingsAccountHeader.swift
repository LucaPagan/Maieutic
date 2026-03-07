import SwiftUI

struct SettingsAccountHeader: View {
    @Binding var nickname: String
    let isGuestMode: Bool
    let email: String?

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.gradient)
                    .frame(width: 52, height: 52)
                Text(avatarInitial)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    TextField("Name", text: $nickname)
                        .font(.system(.title3, design: .rounded).weight(.semibold))
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                    
                    Image(systemName: "pencil")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                if isGuestMode {
                    Text("Guest Mode")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else if let email, !email.isEmpty {
                    Text(email)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
    }

    private var avatarInitial: String {
        let trimmed = nickname.trimmingCharacters(in: .whitespaces)
        return trimmed.first.map(String.init) ?? "?"
    }
}
