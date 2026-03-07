import SwiftUI
import SwiftData

@main
struct MaieuticApp: App {
    @StateObject private var authManager = AuthenticationManager()

    var body: some Scene {
        WindowGroup {
            AppRouter()
                .environmentObject(authManager)
                // Fix spazio nero: forza il background dell'intera window
                .background(Color(uiColor: .secondarySystemBackground))
                .onAppear {
                    // Fix scroll: rimuove gesture recognizer competitor a livello di UIWindow
                    UIScrollView.appearance().panGestureRecognizer.minimumNumberOfTouches = 1
                    UIScrollView.appearance().panGestureRecognizer.maximumNumberOfTouches = 3
                    // Fix spazio nero: rende la tastiera trasparente nel suo container
                    UITextField.appearance().keyboardAppearance = .default
                }
        }
        .modelContainer(for: [AppUser.self, InteractionMetric.self, ChatThread.self, Message.self])
    }
}
