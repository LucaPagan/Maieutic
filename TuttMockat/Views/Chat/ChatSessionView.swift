import SwiftUI
import SwiftData

struct ChatSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var session: GuestSessionManager
    @StateObject private var engine = SocraticEngine()
    @Binding var profile: CalibrationProfile
    @Binding var isSidebarOpened: Bool
    @Binding var activeThread: ChatThread?
    @Binding var showStatistics: Bool
    @Query private var users: [AppUser]

    @State private var inputText: String = ""
    @State private var showProfileSettings = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(engine.messages) { message in
                                    SocraticBubble(message: message)
                                        .id(message.id)
                                }
                                if engine.isTyping {
                                    TypingIndicatorView()
                                        .transition(.opacity)
                                }
                            }
                            .padding(.top, 16)
                            .padding(.bottom, 120)
                            .contentShape(Rectangle())
                            .onTapGesture { hideKeyboard() }
                        }
                        .background(Color.clear)
                        .scrollDismissesKeyboard(.interactively)
                        .onChange(of: engine.messages) { _ in
                            if let last = engine.messages.last {
                                withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                            }
                        }
                    }

                    VStack(spacing: 0) {
                        if engine.profile.currentPhase == .phase2_scaffold && !engine.isTyping {
                            Button {
                                triggerHapticFeedback()
                                withAnimation {
                                    engine.profile.currentPhase = .phase1_xRay
                                }
                                engine.sendMessage("I don't think I can figure this out on my own, could you reveal the answer?", context: session.isGuestMode ? nil : modelContext)
                            } label: {
                                HStack {
                                    Image(systemName: "lightbulb.fill")
                                    Text("Reveal the answer")
                                }
                                .font(.system(.footnote, design: .rounded).bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.orange.gradient)
                                .clipShape(Capsule())
                                .shadow(color: .orange.opacity(0.3), radius: 4, y: 2)
                            }
                            .padding(.bottom, 8)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }

                        InputAreaView(text: $inputText, isEnabled: engine.isModelAvailable, showBorder: !isSidebarOpened, onSend: {
                            engine.sendMessage(inputText, context: session.isGuestMode ? nil : modelContext)
                            inputText = ""
                        }, onAccessoryTap: {})
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation(.smooth(duration: 0.3)) {
                            isSidebarOpened.toggle()
                        }
                    } label: {
                        Image(systemName: "sidebar.left")
                            .font(.system(size: 16, weight: .medium))
                    }
                }
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 1) {
                        Text("Maieutic")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
                        Text("Phase \(engine.profile.currentPhase.rawValue) • \(engine.connectionStatus)")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(engine.connectionStatus.contains("Error") ? .red : .accentColor)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if session.isGuestMode {
                            session.requestUpgrade()
                        } else {
                            showProfileSettings = true
                        }
                    } label: {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.accentColor.gradient)
                    }
                }
            }
            .navigationDestination(isPresented: $showStatistics) {
                StatisticsView()
            }
        }
        .onAppear {
            if let thread = activeThread {
                engine.loadThread(thread)
            } else {
                engine.configure(with: profile)
            }
            engine.updateNickname(users.first?.nickname)
        }
        .onChange(of: users) { _ in
            engine.updateNickname(users.first?.nickname)
        }
        .onChange(of: profile) { newProfile in
            engine.updateProfileContext(newProfile)
        }
        .onChange(of: activeThread) { newThread in
            if let thread = newThread {
                engine.loadThread(thread)
            } else {
                engine.startNewSession()
            }
        }
        .sheet(isPresented: $showProfileSettings) {
            ProfileSettingsView(profile: $profile, user: users.first)
        }
        .sheet(isPresented: $session.showUpgradeSheet) {
            GuestUpgradeSheet(feature: "profile settings")
        }
    }
}
