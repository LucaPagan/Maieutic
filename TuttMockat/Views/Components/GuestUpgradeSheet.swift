import SwiftUI
import AuthenticationServices
import SwiftData

struct GuestUpgradeSheet: View {
    @EnvironmentObject private var session: GuestSessionManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var feature: String = "this feature"
    
    var body: some View {
        VStack(spacing: 24) {
            // Drag indicator
            Capsule()
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
            
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color.accentColor.gradient)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(.white)
            }
            
            // Title & Description
            VStack(spacing: 8) {
                Text("Unlock Full Access")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                
                Text("Sign in with your Apple ID to access \(feature) and save your progress across sessions.")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            Spacer()
            
            // Sign In with Apple
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                handleSignIn(result: result)
            }
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .frame(height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 24)
            
            Button("Not Now") {
                dismiss()
            }
            .font(.system(.subheadline, design: .rounded))
            .foregroundColor(.secondary)
            .padding(.bottom, 32)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }
    
    private func handleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userId = credential.user
                let givenName = credential.fullName?.givenName
                let familyName = credential.fullName?.familyName
                let email = credential.email
                
                let request = FetchDescriptor<AppUser>(predicate: #Predicate { $0.appleUserId == userId })
                
                do {
                    let existing = try modelContext.fetch(request)
                    if existing.isEmpty {
                        let newUser = AppUser(appleUserId: userId, firstName: givenName, lastName: familyName, email: email)
                        modelContext.insert(newUser)
                    }
                    try modelContext.save()
                    session.upgradeFromGuest()
                    dismiss()
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
    Text("Background")
        .sheet(isPresented: .constant(true)) {
            GuestUpgradeSheet(feature: "profile settings")
                .environmentObject(GuestSessionManager())
        }
}
