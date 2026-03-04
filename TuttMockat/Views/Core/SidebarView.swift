import SwiftUI
import SwiftData

struct SidebarView: View {
    @Binding var isShowing: Bool
    @Binding var activeThread: ChatThread?
    @State private var showStatistics: Bool = false
    
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
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isShowing = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.secondary)
                        .padding(8)
                }
            }
            .padding()
            
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
                
                Button {
                    showStatistics = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .background(Color.teal)
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
            .padding(.bottom, 8)
            
            Divider()
                .padding(.vertical, 8)
            
            // Previous Chats Grouped by Domain
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
                                                .foregroundColor(activeThread?.id == thread.id ? .teal : .secondary)
                                            Text(thread.title)
                                                .font(.subheadline)
                                                .foregroundColor(activeThread?.id == thread.id ? .teal : .primary)
                                                .lineLimit(1)
                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 8)
                                        .background(activeThread?.id == thread.id ? Color.teal.opacity(0.1) : Color.clear)
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
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .systemBackground))
        .sheet(isPresented: $showStatistics) {
            StatisticsView()
        }
    }
}
