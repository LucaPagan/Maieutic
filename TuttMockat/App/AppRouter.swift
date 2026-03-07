import SwiftUI
import SwiftData
import Combine

struct AppRouter: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @Query private var users: [AppUser]

    private var needsNickname: Bool {
        guard let user = users.first else { return false }
        let nickname = user.nickname ?? ""
        return nickname.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private enum Route {
        case loading, onboarding, calibration, auth, nickname, main
    }

    private var currentRoute: Route {
        if authManager.isCheckingAuth { return .loading }
        if !authManager.hasSeenIntroOnboarding { return .onboarding }
        if !authManager.isCalibrated { return .calibration }
        if !authManager.isAuthenticated && !authManager.isGuestMode { return .auth }
        if authManager.isAuthenticated && needsNickname { return .nickname }
        return .main
    }

    var body: some View {
        Group {
            switch currentRoute {
            case .loading:
                ZStack {
                    Color.black.ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            case .onboarding:
                OnboardingCarousel()
            case .calibration:
                CalibrationFlow(
                    profile: $authManager.profile,
                    isComplete: Binding(
                        get: { authManager.isCalibrated },
                        set: { _ in authManager.completeCalibration() }
                    )
                )
            case .auth:
                AuthChoiceView()
            case .nickname:
                NicknameSelectionView()
            case .main:
                MainContainer(profile: $authManager.profile)
            }
        }
        .task {
            // Check auth status on load
            await authManager.checkCredentialState()
        }
    }
}

#Preview {
    AppRouter()
        .environmentObject(AuthenticationManager())
        .modelContainer(for: [AppUser.self, InteractionMetric.self, ChatThread.self])
}
