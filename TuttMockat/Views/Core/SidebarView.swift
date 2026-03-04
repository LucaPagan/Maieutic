import SwiftUI
import SwiftData

struct SidebarView: View {
    @Binding var isShowing: Bool
    @Binding var activeThread: ChatThread?
    @Binding var showStatistics: Bool
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var session: GuestSessionManager
    
    @Query(sort: \ChatThread.date, order: .reverse) private var threads: [ChatThread]
    
    private var groupedThreads: [String: [ChatThread]] {
        Dictionary(grouping: threads, by: { $0.domain })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Chats")
                    .font(.title3)
                    .fontWeight(.bold)
                
                if session.isGuestMode {
                    Text("Guest")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.orange.gradient, in: Capsule())
                }
                
                Spacer()
            }
            .padding()
            .padding(.top, 24)
            
            // App Navigation
            VStack(spacing: 8) {
                Button {
                    activeThread = nil
                    withAnimation { isShowing = false }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .background(Color.indigo)
                            .cornerRadius(8)
                        
                        Text("New Chat")
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if !session.isGuestMode {
                    Button {
                        showStatistics = true
                        withAnimation { isShowing = false }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundColor(.white)
                                .frame(width: 30, height: 30)
                                .background(Color.accentColor)
                                .cornerRadius(8)
                            
                            Text("Your Progress")
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.bottom, 8)
            
            Divider()
                .padding(.vertical, 8)
            
            // Previous Chats Grouped by Domain
            if session.isGuestMode {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.accentColor.gradient)
                    Text("Sign in to save your chat history")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        session.requestUpgrade()
                    } label: {
                        Text("Sign In")
                            .font(.system(.subheadline, design: .rounded).bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(Color.accentColor.gradient, in: Capsule())
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if groupedThreads.isEmpty {
                             Text("No past conversations.")
                                 .font(.caption)
                                 .foregroundColor(.secondary)
                                 .padding(.horizontal)
                        } else {
                            ForEach(Array(groupedThreads.keys.sorted()), id: \.self) { domain in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(domain.uppercased())
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal)
                                        .padding(.bottom, 4)
                                    
                                    ForEach(groupedThreads[domain] ?? []) { thread in
                                        Button {
                                            activeThread = thread
                                            withAnimation { isShowing = false }
                                        } label: {
                                            HStack {
                                                Image(systemName: "bubble.left")
                                                    .foregroundColor(activeThread?.id == thread.id ? .accentColor : .secondary)
                                                Text(thread.title)
                                                    .font(.subheadline)
                                                    .foregroundColor(activeThread?.id == thread.id ? .accentColor : .primary)
                                                    .lineLimit(1)
                                                Spacer()
                                            }
                                            .padding(.horizontal)
                                            .padding(.vertical, 8)
                                            .background(activeThread?.id == thread.id ? Color.accentColor.opacity(0.1) : Color.clear)
                                            .cornerRadius(8)
                                            .padding(.horizontal, 8)
                                            .contentShape(Rectangle())
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colorScheme == .dark ? Color(white: 0.11) : Color(white: 0.96))
    }
}
