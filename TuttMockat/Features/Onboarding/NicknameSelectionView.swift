import SwiftUI
import SwiftData
import Combine

struct NicknameSelectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [AppUser]

    @State private var nicknameInput = ""
    @FocusState private var isFocused: Bool

    private var canSave: Bool {
        !nicknameInput.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ZStack {
            Color(uiColor: .secondarySystemBackground).ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                Image(systemName: "character.cursor.ibeam")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(Color(uiColor: .label))
                    .frame(width: 90, height: 90)
                    .glassEffect(.regular, in: .circle)

                VStack(spacing: 12) {
                    Text("Choose a Nickname")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(uiColor: .label))

                    Text("How should we call you?")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                TextField("Nickname", text: $nicknameInput)
                    .font(.system(.title3, design: .rounded))
                    .foregroundStyle(Color(uiColor: .label))
                    .focused($isFocused)
                    .padding()
                    .glassEffect(.regular, in: .rect(cornerRadius: 16))
                    .padding(.horizontal, 24)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)

                Spacer()

                Button(action: saveNickname) {
                    Text("Complete Profile")
                        .fontWeight(.medium)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.glassProminent)
                .buttonSizing(.flexible)
                .disabled(!canSave)
                .opacity(canSave ? 1 : 0.5)
                .padding(.horizontal, 30)
                .padding(.bottom, 24)
            }
        }
    }

    private func saveNickname() {
        guard let user = users.first, canSave else { return }
        user.nickname = nicknameInput.trimmingCharacters(in: .whitespaces)
        try? modelContext.save()
    }
}
