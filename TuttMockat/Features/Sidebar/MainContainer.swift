import SwiftUI
import SwiftData
import Combine

struct MainContainer: View {
    @Binding var profile: CalibrationProfile
    @Query private var users: [AppUser]
    @Environment(\.colorScheme) private var colorScheme

    @State private var isSidebarOpened = false
    @State private var dragOffset: CGFloat = 0
    @State private var activeThread: ChatThread?
    @State private var showStatistics = false
    @State private var showSettings = false

    private let sidebarWidth: CGFloat = 330

    private var currentOffset: CGFloat {
        min(max((isSidebarOpened ? sidebarWidth : 0) + dragOffset, 0), sidebarWidth)
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? Color(white: 0.08) : Color(white: 0.92)
    }

    var body: some View {
        ZStack(alignment: .leading) {
            sidebarLayer
            mainContentLayer
        }
        .background(backgroundColor)
        .ignoresSafeArea()
        .sheet(isPresented: $showSettings) {
            ProfileSettingsView(profile: $profile, user: users.first)
        }
    }

    private var sidebarLayer: some View {
        SidebarView(
            isShowing: $isSidebarOpened,
            activeThread: $activeThread,
            showStatistics: $showStatistics,
            showSettings: $showSettings
        )
        .frame(width: sidebarWidth)
        .safeAreaPadding(.top)
        .opacity(currentOffset > 0 ? 1 : 0)
    }

    private var mainContentLayer: some View {
        ChatView(
            profile: $profile,
            isSidebarOpened: $isSidebarOpened,
            activeThread: $activeThread,
            showStatistics: $showStatistics
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .dismissKeyboardOnTap()
        .background(colorScheme == .dark ? Color(white: 0.11) : .white)
        .clipShape(RoundedRectangle(cornerRadius: 60))
        .overlay(
            RoundedRectangle(cornerRadius: 60)
                .stroke(Color(uiColor: .separator), lineWidth: 1)
                .opacity(currentOffset > 0 ? 1 : 0)
        )
        .opacity(1 - (currentOffset / sidebarWidth) * 0.5)
        .offset(x: currentOffset)
        .simultaneousGesture(sidebarDragGesture)
    }

    private var sidebarDragGesture: some Gesture {
        DragGesture(minimumDistance: 20, coordinateSpace: .local)
            .onChanged { value in
                // Ignora completamente se il gesto è più verticale che orizzontale
                let isHorizontal = abs(value.translation.width) > abs(value.translation.height) * 1.5
                guard isHorizontal else { return }
                if dragOffset == 0 { hideKeyboard() }
                dragOffset = value.translation.width
            }
            .onEnded { value in
                let isHorizontal = abs(value.translation.width) > abs(value.translation.height) * 1.5
                guard isHorizontal else {
                    withAnimation(.smooth(duration: 0.3)) { dragOffset = 0 }
                    return
                }
                let predicted = currentOffset + value.predictedEndTranslation.width * 0.3
                withAnimation(.smooth(duration: 0.3)) {
                    isSidebarOpened = predicted > sidebarWidth * 0.4
                    dragOffset = 0
                }
            }
    }
}
