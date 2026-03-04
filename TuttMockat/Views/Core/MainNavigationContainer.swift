import SwiftUI

struct MainNavigationContainer: View {
    @Binding var profile: CalibrationProfile
    @State private var isSidebarOpened = false
    @State private var activeThread: ChatThread?
    
    // Sidebar width
    private let menuWidth: CGFloat = UIScreen.main.bounds.width * 0.75
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Main Content Layer
            ChatSessionView(profile: $profile, isSidebarOpened: $isSidebarOpened, activeThread: $activeThread)
                // Disabilita l'interazione del main view quando la sidebar è aperta
                .disabled(isSidebarOpened)
            
            // Dim Overlay Layer
            if isSidebarOpened {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isSidebarOpened = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(1)
            }
            
            // Sidebar Layer
            if isSidebarOpened {
                SidebarView(isShowing: $isSidebarOpened, activeThread: $activeThread)
                    .frame(width: menuWidth)
                    .transition(.move(edge: .leading))
                    .zIndex(2)
            }
        }
        // Swipe to close
        .gesture(
            DragGesture()
                .onEnded { value in
                    if isSidebarOpened && value.translation.width < -50 {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isSidebarOpened = false
                        }
                    }
                }
        )
    }
}
