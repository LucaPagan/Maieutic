import SwiftUI
import Combine
import AuthenticationServices

@MainActor
class AuthenticationManager: ObservableObject {
    @AppStorage("hasSeenIntroOnboarding") var hasSeenIntroOnboarding = false
    @AppStorage("isGuestMode") var isGuestMode = false
    @AppStorage("isCalibrated") var isCalibrated = false
    
    private let profileKeychainService = "app-profile"
    private let profileKeychainAccount = "currentUserData"

    @Published var profile = CalibrationProfile()
    
    // Auth State Source of Truth
    @Published var isAuthenticated = false
    @Published var isCheckingAuth = true

    private let appleAuthService = "apple-auth"
    private let appleAccountUserId = "userIdentifier"

    init() {
        if let savedData = KeychainHelper.standard.read(service: profileKeychainService, account: profileKeychainAccount),
           let decoded = try? JSONDecoder().decode(CalibrationProfile.self, from: savedData) {
            self.profile = decoded
        }
    }
    
    func checkCredentialState() async {
        isCheckingAuth = true
        defer { isCheckingAuth = false }
        
        if isGuestMode {
            self.isAuthenticated = false
            return
        }
        
        if let userIdData = KeychainHelper.standard.read(service: appleAuthService, account: appleAccountUserId),
           let userId = String(data: userIdData, encoding: .utf8), !userId.isEmpty {
            
            let provider = ASAuthorizationAppleIDProvider()
            do {
                let state = try await provider.credentialState(forUserID: userId)
                switch state {
                case .authorized:
                    self.isAuthenticated = true
                case .revoked, .notFound:
                    self.signOut()
                default:
                    self.signOut()
                }
            } catch {
                self.signOut()
            }
        } else {
            self.isAuthenticated = false
        }
    }

    func completeIntroOnboarding() {
        withAnimation(.easeInOut) {
            hasSeenIntroOnboarding = true
        }
    }

    func completeCalibration() {
        saveProfile()
        withAnimation(.easeInOut) {
            isCalibrated = true
        }
    }

    func enterGuestMode() {
        withAnimation(.easeInOut) {
            isGuestMode = true
            isAuthenticated = false
        }
    }

    func upgradeFromGuest() {
        isGuestMode = false
    }

    func saveProfile() {
        if let encoded = try? JSONEncoder().encode(profile) {
            KeychainHelper.standard.save(encoded, service: profileKeychainService, account: profileKeychainAccount)
        }
    }

    func saveAppleUserId(_ userId: String) {
        if let data = userId.data(using: .utf8) {
            KeychainHelper.standard.save(data, service: appleAuthService, account: appleAccountUserId)
            isAuthenticated = true
            isGuestMode = false
        }
    }

    func signOut() {
        KeychainHelper.standard.delete(service: appleAuthService, account: appleAccountUserId)
        isGuestMode = true
        isAuthenticated = false
    }

    func reset() {
        hasSeenIntroOnboarding = false
        isGuestMode = false
        isCalibrated = false
        profile = CalibrationProfile()
        KeychainHelper.standard.delete(service: profileKeychainService, account: profileKeychainAccount)
        signOut()
    }
}
