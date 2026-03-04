import SwiftUI
import AuthenticationServices
import SwiftData

struct SignInView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [AppUser]
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundColor(.teal)
                .accessibilityHidden(true)
            
            VStack(spacing: 8) {
                Text("CogniGuard Access")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                
                Text("Sign in to start your cognitive rehabilitation journey securely.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                handleSignIn(result: result)
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
            .accessibilityLabel("Sign In with Apple")
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
    }
    
    private func handleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userId = appleIDCredential.user
                let givenName = appleIDCredential.fullName?.givenName
                let familyName = appleIDCredential.fullName?.familyName
                let email = appleIDCredential.email
                
                // Cerca se l'utente esiste già
                let request = FetchDescriptor<AppUser>(predicate: #Predicate { $0.appleUserId == userId })
                
                do {
                    let existingUsers = try modelContext.fetch(request)
                    if existingUsers.isEmpty {
                        // Nuovo utente
                        let newUser = AppUser(appleUserId: userId, firstName: givenName, lastName: familyName, email: email, hasSeenWelcome: false)
                        modelContext.insert(newUser)
                    } else {
                        // Utente esistente: SwiftData traccia automaticamente le entità
                        print("Utente loggato con successo: \\(userId)")
                    }
                    try modelContext.save()
                } catch {
                    print("Errore nel salvataggio utente in SwiftData: \\(error.localizedDescription)")
                }
            }
        case .failure(let error):
            print("Autenticazione Apple fallita: \\(error.localizedDescription)")
        }
    }
}
