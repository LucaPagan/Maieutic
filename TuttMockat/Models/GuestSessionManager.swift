import SwiftUI
import SwiftData
import Combine

@MainActor
class GuestSessionManager: ObservableObject {
    // MARK: - Persisted State
    @AppStorage("hasSeenIntroOnboarding") var hasSeenIntroOnboarding: Bool = false
    @AppStorage("isGuestMode") var isGuestMode: Bool = false
    @AppStorage("isCalibrated") var isCalibrated: Bool = false
    @AppStorage("savedProfile") private var savedProfileData: Data = Data()
    
    // MARK: - In-Memory State
    @Published var profile: CalibrationProfile = CalibrationProfile()
    @Published var showUpgradeSheet: Bool = false
    
    init() {
        // Restore profile from AppStorage if available
        if let decoded = try? JSONDecoder().decode(CalibrationProfile.self, from: savedProfileData) {
            self.profile = decoded
        }
    }
    
    // MARK: - Computed
    
    /// Whether the user has signed in with Apple ID (has an AppUser in SwiftData)
    /// This is checked externally via @Query in ContentView
    var isAuthenticated: Bool {
        // Determined externally by checking AppUser existence
        false // placeholder, actual check in ContentView
    }
    
    var needsAuthChoice: Bool {
        !isGuestMode // If not guest, we need either auth or guest choice
    }
    
    // MARK: - Actions
    
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
        }
    }
    
    func upgradeFromGuest() {
        isGuestMode = false
        showUpgradeSheet = false
    }
    
    func requestUpgrade() {
        showUpgradeSheet = true
    }
    
    func saveProfile() {
        if let encoded = try? JSONEncoder().encode(profile) {
            savedProfileData = encoded
        }
    }
    
    /// Full reset (for testing / sign out)
    func reset() {
        hasSeenIntroOnboarding = false
        isGuestMode = false
        isCalibrated = false
        profile = CalibrationProfile()
        savedProfileData = Data()
    }
}
