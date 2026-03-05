import SwiftUI

struct MainNavigationContainer: View {
    @Binding var profile: CalibrationProfile
    @State private var isSidebarOpened = false
    @State private var dragOffset: CGFloat = 0
    @State private var activeThread: ChatThread?
    @State private var showStatistics = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { geometry in
            let sidebarWidth = geometry.size.width * 0.78
            
            ZStack(alignment: .leading) {
                // Sidebar Layer (behind main content)
                SidebarView(isShowing: $isSidebarOpened, activeThread: $activeThread, showStatistics: $showStatistics)
                    .frame(width: sidebarWidth)
                    .safeAreaPadding(.top)
                    .opacity(currentOffset(sidebarWidth: sidebarWidth) > 0 ? 1 : 0)

                // Main Content Layer
                ChatSessionView(
                    profile: $profile,
                    isSidebarOpened: $isSidebarOpened,
                    activeThread: $activeThread,
                    showStatistics: $showStatistics
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(uiColor: .systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: currentOffset(sidebarWidth: sidebarWidth) > 0 ? 40 : 0))
                .overlay(
                    RoundedRectangle(cornerRadius: currentOffset(sidebarWidth: sidebarWidth) > 0 ? 40 : 0)
                        .stroke(Color(.separator), lineWidth: currentOffset(sidebarWidth: sidebarWidth) > 0 ? 1 : 0)
                )
                .opacity(1 - (currentOffset(sidebarWidth: sidebarWidth) / sidebarWidth) * 0.5)
                .offset(x: currentOffset(sidebarWidth: sidebarWidth))
                .shadow(
                    color: .black.opacity(currentOffset(sidebarWidth: sidebarWidth) > 0 ? 0.3 : 0),
                    radius: 12,
                    x: -4
                )
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onChanged { value in
                            let horizontal = abs(value.translation.width)
                            let vertical = abs(value.translation.height)
                            guard horizontal > vertical else { return }
                            dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            let velocity = value.predictedEndTranslation.width
                            let finalPosition = currentOffset(sidebarWidth: sidebarWidth) + velocity * 0.3
                            withAnimation(.smooth(duration: 0.3)) {
                                isSidebarOpened = finalPosition > sidebarWidth * 0.4
                                dragOffset = 0
                            }
                        }
                )
            }
        }
        .background(
            colorScheme == .dark
                ? Color(white: 0.11)
                : Color(white: 0.96)
        )
        .ignoresSafeArea()
        .animation(.smooth(duration: 0.3), value: isSidebarOpened)
    }
    
    private func currentOffset(sidebarWidth: CGFloat) -> CGFloat {
        let base: CGFloat = isSidebarOpened ? sidebarWidth : 0
        return min(max(base + dragOffset, 0), sidebarWidth)
    }
}
