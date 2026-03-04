import SwiftUI
import AuthenticationServices
import SwiftData

struct AuthChoiceView: View {
    @EnvironmentObject private var session: GuestSessionManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color(white: 0.11) : Color(white: 0.96))
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.accentColor.gradient)
                        .frame(width: 100, height: 100)
                        .shadow(color: Color.accentColor.opacity(0.3), radius: 16, y: 8)
                    
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .font(.system(size: 44, weight: .medium))
                        .foregroundStyle(.white)
                }
                
                // Title & Description
                VStack(spacing: 12) {
                    Text("Almost There")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                    
                    Text("Sign in to save your progress, sync chat history, and unlock all features.")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                // Actions
                VStack(spacing: 16) {
                    // Sign In with Apple
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        handleSignIn(result: result)
                    }
                    .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                    .frame(height: 54)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 24)
                    
                    // Continue without account
                    Button {
                        session.enterGuestMode()
                    } label: {
                        Text("Continue without an account")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
                
                // Privacy disclaimer
                Text("Your data stays on your device. We use Apple Intelligence for all AI processing.")
                    .font(.caption2)
                    .foregroundColor(.secondary.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
            }
        }
    }
    
    private func handleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userId = credential.user
                let givenName = credential.fullName?.givenName
                let familyName = credential.fullName?.familyName
                let email = credential.email
                let authCode = credential.authorizationCode.flatMap { String(data: $0, encoding: .utf8) }
                
                let request = FetchDescriptor<AppUser>(predicate: #Predicate { $0.appleUserId == userId })
                
                do {
                    let existingUsers = try modelContext.fetch(request)
                    if existingUsers.isEmpty {
                        let newUser = AppUser(appleUserId: userId, firstName: givenName, lastName: familyName, email: email, authorizationCode: authCode)
                        modelContext.insert(newUser)
                    } else if let existingUser = existingUsers.first, let code = authCode {
                        existingUser.authorizationCode = code
                    }
                    try modelContext.save()
                    session.upgradeFromGuest()
                } catch {
                    print("Error saving user: \(error.localizedDescription)")
                }
            }
        case .failure(let error):
            print("Apple Sign-In failed: \(error.localizedDescription)")
        }
    }
}

#Preview {
    AuthChoiceView()
        .environmentObject(GuestSessionManager())
}
