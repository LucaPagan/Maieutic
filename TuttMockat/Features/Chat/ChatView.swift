import SwiftUI
import SwiftData
import Combine

struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var authManager: AuthenticationManager
    @StateObject private var engine = SocraticEngine()
    @Binding var profile: CalibrationProfile
    @Binding var isSidebarOpened: Bool
    @Binding var activeThread: ChatThread?
    @Binding var showStatistics: Bool
    @Query private var users: [AppUser]

    @State private var inputText = ""

    var body: some View {
        NavigationStack {
                VStack(spacing: 0) {
                    if engine.messages.isEmpty {
                        ChatEmptyState(inputText: $inputText)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                hideKeyboard()
                                if isSidebarOpened {
                                    withAnimation(.smooth(duration: 0.3)) { isSidebarOpened = false }
                                }
                            }
                    } else {
                        MessageList(messages: engine.messages, isTyping: engine.isTyping)
                    }

                    InputBar(
                        text: $inputText,
                        isEnabled: engine.isModelAvailable,
                        showBorder: !isSidebarOpened,
                        onSend: {
                            engine.sendMessage(inputText, context: authManager.isGuestMode ? nil : modelContext)
                            inputText = ""
                        }
                    )
                }
                .background(Color(uiColor: .secondarySystemBackground).ignoresSafeArea())
                // Fix spazio nero: il background estende sotto la tastiera
                .background(Color(uiColor: .secondarySystemBackground).ignoresSafeArea(.keyboard))
                .sensoryFeedback(.impact(flexibility: .soft), trigger: engine.messages.count)
                .toolbar {
                    ChatToolbar(
                        onToggleSidebar: {
                            hideKeyboard()
                            withAnimation(.smooth(duration: 0.3)) { isSidebarOpened.toggle() }
                        },
                        onNewChat: {
                            activeThread = nil
                            engine.startNewSession()
                        }
                    )
                }
                .navigationDestination(isPresented: $showStatistics) {
                    StatisticsView()
                }
            }.onAppear {
            if let thread = activeThread {
                engine.loadThread(thread)
            } else {
                engine.configure(with: profile)
            }
            engine.updateNickname(users.first?.nickname)
        }
        .onChange(of: profile) { _, newProfile in
            engine.updateProfileContext(newProfile)
        }
        .onChange(of: engine.messages.count) {
            withAnimation(.easeOut(duration: 0.25)) { } 
        }
        .onChange(of: activeThread) { _, newThread in
            if let thread = newThread {
                engine.loadThread(thread)
            } else {
                engine.startNewSession()
                engine.configure(with: profile)
            }
        }
        .onChange(of: users.first?.nickname) { _, newNickname in
            engine.updateNickname(newNickname)
        }
    }
}

#Preview {
    ChatView(
        profile: .constant(CalibrationProfile()),
        isSidebarOpened: .constant(false),
        activeThread: .constant(nil),
        showStatistics: .constant(false)
    )
    .environmentObject(AuthenticationManager())
    .modelContainer(for: [AppUser.self, ChatThread.self, InteractionMetric.self])
}
