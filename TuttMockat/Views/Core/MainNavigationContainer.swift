import SwiftUI

struct MainNavigationContainer: View {
    @Binding var profile: CalibrationProfile
    @State private var isSidebarOpened = false
    @State private var dragOffset: CGFloat = 0
    @State private var activeThread: ChatThread?
    @State private var showStatistics = false
    @Environment(\.colorScheme) private var colorScheme

    private let sidebarWidth: CGFloat = UIScreen.main.bounds.width * 0.78

    private var currentOffset: CGFloat {
        let base: CGFloat = isSidebarOpened ? sidebarWidth : 0
        return min(max(base + dragOffset, 0), sidebarWidth)
    }

    var body: some View {
        ZStack(alignment: .leading) {
            // Sidebar Layer (behind main content)
            SidebarView(isShowing: $isSidebarOpened, activeThread: $activeThread, showStatistics: $showStatistics)
                .frame(width: sidebarWidth)
                .safeAreaPadding(.top)
                .opacity(currentOffset > 0 ? 1 : 0)

            // Main Content Layer
            ChatSessionView(
                profile: $profile,
                isSidebarOpened: $isSidebarOpened,
                activeThread: $activeThread,
                showStatistics: $showStatistics
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: currentOffset > 0 ? 40 : 0))
            .overlay(
                RoundedRectangle(cornerRadius: currentOffset > 0 ? 40 : 0)
                    .stroke(Color(.separator), lineWidth: currentOffset > 0 ? 1 : 0)
            )
            .opacity(1 - (currentOffset / sidebarWidth) * 0.5)
            .offset(x: currentOffset)
            .shadow(
                color: .black.opacity(currentOffset > 0 ? 0.3 : 0),
                radius: 12,
                x: -4
            )
            .highPriorityGesture(
                DragGesture(minimumDistance: 15)
                    .onChanged { value in
                        let horizontal = abs(value.translation.width)
                        let vertical = abs(value.translation.height)
                        guard horizontal > vertical else { return }
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        let velocity = value.predictedEndTranslation.width
                        let finalPosition = currentOffset + velocity * 0.3
                        withAnimation(.smooth(duration: 0.3)) {
                            isSidebarOpened = finalPosition > sidebarWidth * 0.4
                            dragOffset = 0
                        }
                    }
            )
        }
        .background(
            colorScheme == .dark
                ? Color(white: 0.11)
                : Color(white: 0.96)
        )
        .ignoresSafeArea()
        .animation(.smooth(duration: 0.3), value: isSidebarOpened)
    }
}
