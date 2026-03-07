import SwiftUI
import SwiftData

struct CategorySection: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext

    var category: String
    var threads: [ChatThread]
    var isRecents: Bool = false
    @Binding var isCollapsed: Bool
    var onSelect: (ChatThread) -> Void

    @State private var threadToDelete: ChatThread?
    @State private var threadToRename: ChatThread?
    @State private var renameText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            headerButton
            cardContent
        }
        .alert("Delete Conversation", isPresented: Binding(
            get: { threadToDelete != nil },
            set: { if !$0 { threadToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) { threadToDelete = nil }
            Button("Delete", role: .destructive) {
                if let thread = threadToDelete {
                    withAnimation(.smooth(duration: 0.25)) { modelContext.delete(thread) }
                    try? modelContext.save()
                }
                threadToDelete = nil
            }
        } message: {
            Text("Are you sure? This action cannot be undone.")
        }
        .alert("Rename Conversation", isPresented: Binding(
            get: { threadToRename != nil },
            set: { if !$0 { threadToRename = nil } }
        )) {
            TextField("Name", text: $renameText)
            Button("Cancel", role: .cancel) { threadToRename = nil }
            Button("Rename") {
                if let thread = threadToRename {
                    thread.title = renameText
                    try? modelContext.save()
                }
                threadToRename = nil
            }
        }
    }

    private var headerButton: some View {
        Button {
            withAnimation(.smooth(duration: 0.25)) { isCollapsed.toggle() }
        } label: {
            HStack(spacing: 6) {
                if isRecents {
                    Text(category)
                        .font(.body.weight(.semibold))
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.6))
                } else {
                    Text(category.uppercased())
                        .font(.caption.weight(.bold))
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.45))
                        .tracking(1.2)
                    Text("\(threads.count)")
                        .font(.caption2.weight(.medium))
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.3) : .black.opacity(0.3))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.3) : .black.opacity(0.3))
                    .rotationEffect(.degrees(isCollapsed ? 0 : 90))
            }
            .padding(.leading, 4)
            .padding(.trailing, 8)
        }
    }

    private var cardContent: some View {
        Group {
            if !isRecents && threads.count >= 5 {
                ScrollView {
                    threadList.padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
                .frame(maxHeight: 220)
                .overlay(alignment: .bottom) {
                    LinearGradient(
                        colors: [
                            colorScheme == .dark ? Color(white: 0.08) : Color(white: 0.93),
                            colorScheme == .dark ? Color(white: 0.08).opacity(0.8) : Color(white: 0.93).opacity(0.8),
                            .clear
                        ],
                        startPoint: .bottom, endPoint: .top
                    )
                    .frame(height: 70)
                    .allowsHitTesting(false)
                }
            } else {
                threadList
            }
        }
        .frame(maxHeight: isCollapsed ? 0 : nil)
        .clipped()
        .opacity(isCollapsed ? 0 : 1)
    }

    private var threadList: some View {
        VStack {
            ForEach(Array(threads.enumerated()), id: \.element.id) { index, thread in
                Button { onSelect(thread) } label: {
                    HStack {
                        Text(thread.title)
                            .font(.subheadline)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                }
                .contextMenu {
                    Button {
                        renameText = thread.title
                        threadToRename = thread
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }
                    Divider()
                    Button(role: .destructive) {
                        threadToDelete = thread
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }

                if index < threads.count - 1 {
                    Divider().padding(.leading, 16)
                }
            }
        }
    }
}
