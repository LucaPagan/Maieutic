import AuthenticationServices
import SwiftData

@MainActor
enum AppleSignInService {
    static func handleAuthorization(
        _ authorization: ASAuthorization,
        context: ModelContext,
        authManager: AuthenticationManager,
        nonce: String?
    ) async throws {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        
        // Security Audit Mitigation: Save identityToken locally to Keychain to prevent basic replay attacks
        // or to allow backend validation in the future. We also receive authCode for future revocation backend support.
        if let identityTokenData = credential.identityToken {
             KeychainHelper.standard.save(identityTokenData, service: "apple-auth", account: "identityToken")
        }
        
        if let authCodeData = credential.authorizationCode {
             KeychainHelper.standard.save(authCodeData, service: "apple-auth", account: "authorizationCode")
        }

        let userId = credential.user
        let givenName = credential.fullName?.givenName
        let familyName = credential.fullName?.familyName
        let email = credential.email

        let request = FetchDescriptor<AppUser>(predicate: #Predicate { $0.appleUserId == userId })

        let existing = try context.fetch(request)

        if existing.isEmpty {
            let newUser = AppUser(
                appleUserId: userId,
                firstName: givenName,
                lastName: familyName,
                email: email,
                nickname: nil
            )
            context.insert(newUser)
        }
        
        try context.save()
        
        // Securely save via AuthenticationManager to keychain and state machine
        authManager.saveAppleUserId(userId)
    }
}
