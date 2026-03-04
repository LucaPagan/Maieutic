import SwiftUI
import SwiftData

struct ChatSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var engine = SocraticEngine()
    @Binding var profile: CalibrationProfile
    @Binding var isSidebarOpened: Bool
    @Binding var activeThread: ChatThread?
    
    @State private var inputText: String = ""
    @State private var showFeatureAlert = false
    @State private var showProfileSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(status: engine.connectionStatus) {
                // onMenuTap
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isSidebarOpened.toggle()
                }
            } onProfileTap: {
                showProfileSettings = true
            }
            .zIndex(1)
            
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
                        .padding(.bottom, 90)
                    }
                    .background(Color.clear)
                    .onTapGesture { hideKeyboard() }
                    .onChange(of: engine.messages) { _ in
                        if let last = engine.messages.last {
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                }
                
                InputAreaView(text: $inputText, isEnabled: engine.isModelAvailable, onSend: {
                    engine.sendMessage(inputText, context: modelContext)
                    inputText = ""
                }, onAccessoryTap: {
                    triggerHapticFeedback()
                    showFeatureAlert = true
                })
            }
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .onAppear {
            if let thread = activeThread {
                engine.loadThread(thread)
            } else {
                engine.configure(with: profile)
            }
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
        .alert("Text-Only Protocol", isPresented: $showFeatureAlert) {
            Button("Got it", role: .cancel) { }
        } message: {
            Text("The current cognitive rehabilitation phase requires text-based interaction to effectively rebuild mental models. Media attachments are disabled.")
        }
        .sheet(isPresented: $showProfileSettings) {
            ProfileSettingsView(profile: $profile)
        }
    }
}
