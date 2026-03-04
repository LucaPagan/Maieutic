import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [AppUser]
    
    @State private var profile = CalibrationProfile()
    @State private var isCalibrated: Bool = false
    
    var body: some View {
        Group {
            if let user = users.first {
                // Utente autenticato: la logica prosegue normalmente ma si appoggia al modello SwiftData
                if !user.hasSeenWelcome {
                    WelcomeView(hasSeenWelcome: Binding(
                        get: { user.hasSeenWelcome },
                        set: { newValue in
                            user.hasSeenWelcome = newValue
                            try? modelContext.save()
                        }
                    ))
                } else if isCalibrated {
                    MainNavigationContainer(profile: $profile)
                } else {
                    OnboardingFlowView(profile: $profile, isComplete: $isCalibrated)
                }
            } else {
                // Nessun utente, mostra il login
                SignInView()
            }
        }
        .animation(.easeInOut, value: isCalibrated)
        .animation(.easeInOut, value: users.first?.hasSeenWelcome)
    }
}
