import SwiftUI
import SwiftData
import Combine
import AuthenticationServices

struct SidebarView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var authManager: AuthenticationManager

    @Binding var isShowing: Bool
    @Binding var activeThread: ChatThread?
    @Binding var showStatistics: Bool
    @Binding var showSettings: Bool

    @Query(sort: \ChatThread.date, order: .reverse) private var threads: [ChatThread]
    @Query private var users: [AppUser]

    @State private var collapsedCategories: Set<String>
    @State private var searchText = ""
    @State private var currentNonce: String?

    init(isShowing: Binding<Bool>, activeThread: Binding<ChatThread?>, showStatistics: Binding<Bool>, showSettings: Binding<Bool>) {
        _isShowing = isShowing
        _activeThread = activeThread
        _showStatistics = showStatistics
        _showSettings = showSettings
        _collapsedCategories = State(initialValue: [])
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? Color(white: 0.08) : Color(white: 0.93)
    }

    private var filteredThreads: [ChatThread] {
        guard !searchText.isEmpty else { return threads }
        return threads.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    private var recentThreads: [ChatThread] {
        Array(filteredThreads.prefix(5))
    }

    private var groupedThreads: [(domain: String, threads: [ChatThread])] {
        Dictionary(grouping: filteredThreads, by: \.domain)
            .sorted { $0.key < $1.key }
            .map { (domain: $0.key, threads: $0.value) }
    }

    var body: some View {
        VStack {
            if !authManager.isGuestMode { searchBar }

            if authManager.isGuestMode {
                guestState
            } else if threads.isEmpty {
                emptyState
            } else if filteredThreads.isEmpty {
                noResultsState
            } else {
                threadsList
            }

            Spacer(minLength: 0)

            if !authManager.isGuestMode { profileButton }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
        .onAppear {
            collapsedCategories = Set(threads.map(\.domain))
        }
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            TextField("Search", text: $searchText)
                .font(.subheadline)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 20))
        .padding(.leading, 16)
        .padding(.trailing, 40)
        .padding(.top, 47)
        .padding(.bottom, 12)
    }

    // MARK: - States

    private var guestState: some View {
        VStack(spacing: 15) {
            Spacer()
            Text("Sign in to see your full history\nacross all your sessions.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            SignInWithAppleButton(.signIn) { request in
                let nonce = CryptoHelper.randomNonceString()
                currentNonce = nonce
                request.requestedScopes = [.fullName, .email]
                request.nonce = CryptoHelper.sha256(nonce)
            } onCompletion: { result in
                if case .success(let authorization) = result {
                    Task {
                        try? await AppleSignInService.handleAuthorization(authorization, context: modelContext, authManager: authManager, nonce: currentNonce)
                    }
                }
            }
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .frame(height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 40))
            .padding(.horizontal, 24)
            .padding(.top, 4)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 36, weight: .thin))
                .foregroundStyle(.tertiary)
            Text("No Conversations")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var noResultsState: some View {
        VStack(spacing: 10) {
            Text("No Results")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Text("Try a different search")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Thread List

    private var threadsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                CategorySection(
                    category: "Recents", threads: recentThreads, isRecents: true,
                    isCollapsed: collapsedBinding(for: "Recents"), onSelect: selectThread
                )

                ForEach(groupedThreads, id: \.domain) { group in
                    CategorySection(
                        category: group.domain, threads: group.threads,
                        isCollapsed: collapsedBinding(for: group.domain), onSelect: selectThread
                    )
                }

                if !authManager.isGuestMode {
                    Button {
                        showStatistics = true
                        withAnimation { isShowing = false }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.caption.weight(.medium))
                            Text("Your Progress")
                                .font(.caption.weight(.medium))
                        }
                        .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 40)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Profile

    private var profileButton: some View {
        Button { showSettings = true } label: {
            HStack(spacing: 10) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.accentColor.gradient)
                Text(profileName)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .glassEffect(.regular, in: Capsule())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 16)
        .padding(.bottom, 32)
    }

    private var profileName: String {
        if let user = users.first {
            if let nickname = user.nickname, !nickname.isEmpty { return nickname }
            if let first = user.firstName, !first.isEmpty { return first }
        }
        return "Profile"
    }

    // MARK: - Helpers

    private func selectThread(_ thread: ChatThread) {
        activeThread = thread
        withAnimation(.smooth(duration: 0.3)) { isShowing = false }
    }

    private func collapsedBinding(for category: String) -> Binding<Bool> {
        Binding(
            get: { collapsedCategories.contains(category) },
            set: { collapsed in
                if collapsed { collapsedCategories.insert(category) }
                else { collapsedCategories.remove(category) }
            }
        )
    }
}
