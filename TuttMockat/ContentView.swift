import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var session: GuestSessionManager
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [AppUser]
    
    /// True if at least one AppUser exists in SwiftData (signed in with Apple)
    private var isAuthenticated: Bool {
        !users.isEmpty
    }
    
    /// True if the authenticated user has set a nickname
    private var hasNickname: Bool {
        users.first?.nickname?.isEmpty == false
    }
    
    var body: some View {
        Group {
            if !session.hasSeenIntroOnboarding {
                // Step 1: First-time intro onboarding
                AppOnboardingView()
            } else if !session.isCalibrated {
                // Step 2: Calibration (domain, weakness, etc.)
                OnboardingFlowView(profile: $session.profile, isComplete: Binding(
                    get: { session.isCalibrated },
                    set: { _ in session.completeCalibration() }
                ))
            } else if !isAuthenticated && !session.isGuestMode {
                // Step 3: Auth choice (Apple ID or Guest)
                AuthChoiceView()
            } else if isAuthenticated && !hasNickname {
                // Step 3.5: Nickname Selection (only for Apple ID users missing a nickname)
                NicknameSelectionView()
            } else {
                // Step 4: Main app (full or guest mode)
                MainNavigationContainer(profile: $session.profile)
            }
        }
        .animation(.easeInOut, value: session.hasSeenIntroOnboarding)
        .animation(.easeInOut, value: session.isCalibrated)
        .animation(.easeInOut, value: session.isGuestMode)
        .animation(.easeInOut, value: isAuthenticated)
    }
}
