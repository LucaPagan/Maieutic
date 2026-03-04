import SwiftUI
import SwiftData

struct NicknameSelectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query private var users: [AppUser]
    
    @State private var nicknameInput: String = ""
    @State private var isFocused: Bool = false
    
    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color(white: 0.11) : Color(white: 0.96))
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Icon Header
                ZStack {
                    Circle()
                        .fill(Color.accentColor.gradient)
                        .frame(width: 90, height: 90)
                        .shadow(color: Color.accentColor.opacity(0.3), radius: 16, y: 8)
                    
                    Image(systemName: "character.cursor.ibeam")
                        .font(.system(size: 38, weight: .medium))
                        .foregroundStyle(.white)
                }
                
                // Title & Description
                VStack(spacing: 12) {
                    Text("Choose a Nickname")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    
                    Text("How should the Socratic Engine address you during your deep thinking sessions?")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                // Input Field
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Nickname", text: $nicknameInput, onEditingChanged: { editing in
                        withAnimation { isFocused = editing }
                    })
                    .font(.system(.title3, design: .rounded))
                    .padding()
                    .background(colorScheme == .dark ? Color(.systemGray6) : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isFocused ? Color.accentColor : Color.primary.opacity(0.1), lineWidth: isFocused ? 2 : 1)
                    )
                    .shadow(color: isFocused ? Color.accentColor.opacity(0.15) : .black.opacity(0.05), radius: isFocused ? 8 : 4, y: 2)
                    .padding(.horizontal, 24)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
                }
                
                Spacer()
                
                // Continue Button
                Button(action: saveNickname) {
                    Text("Complete Profile")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(nicknameInput.trimmingCharacters(in: .whitespaces).isEmpty ? Color.accentColor.opacity(0.5) : Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: nicknameInput.trimmingCharacters(in: .whitespaces).isEmpty ? .clear : Color.accentColor.opacity(0.3), radius: 8, y: 4)
                }
                .disabled(nicknameInput.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
    
    private func saveNickname() {
        guard let user = users.first, !nicknameInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        user.nickname = nicknameInput.trimmingCharacters(in: .whitespaces)
        try? modelContext.save()
    }
}

#Preview {
    NicknameSelectionView()
}
