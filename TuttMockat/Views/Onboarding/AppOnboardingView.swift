import SwiftUI

struct AppOnboardingView: View {
    @EnvironmentObject private var session: GuestSessionManager
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "brain.head.profile",
            title: "Rebuild Your\nCritical Thinking",
            description: "Maieutic helps you overcome AI dependency by teaching you to think independently again.",
            gradient: [.purple, .indigo]
        ),
        OnboardingPage(
            icon: "questionmark.bubble.fill",
            title: "The Socratic\nMethod",
            description: "Instead of giving you answers, Maieutic asks the right questions to guide your reasoning.",
            gradient: [.blue, .cyan]
        ),
        OnboardingPage(
            icon: "arrow.up.right.circle.fill",
            title: "Progressive\nChallenges",
            description: "Four adaptive phases gradually reduce AI assistance as your confidence grows.",
            gradient: [.orange, .red]
        ),
        OnboardingPage(
            icon: "lock.shield.fill",
            title: "Private &\nOn-Device",
            description: "All AI processing happens directly on your device with Apple Intelligence. Your data never leaves your phone.",
            gradient: [.green, .mint]
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            (colorScheme == .dark ? Color(white: 0.11) : Color(white: 0.96))
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            session.completeIntroOnboarding()
                        }
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.trailing, 24)
                        .padding(.top, 16)
                    }
                }
                .frame(height: 44)
                
                // Pages
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        pageView(for: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.smooth(duration: 0.4), value: currentPage)
                
                // Page Indicator + Button
                VStack(spacing: 28) {
                    // Custom page dots
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? Color.accentColor : Color(.systemGray4))
                                .frame(width: index == currentPage ? 24 : 8, height: 8)
                                .animation(.smooth(duration: 0.3), value: currentPage)
                        }
                    }
                    
                    // Continue / Get Started button
                    Button {
                        if currentPage < pages.count - 1 {
                            withAnimation(.smooth(duration: 0.4)) {
                                currentPage += 1
                            }
                        } else {
                            session.completeIntroOnboarding()
                        }
                    } label: {
                        Text(currentPage < pages.count - 1 ? "Continue" : "Get Started")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.accentColor.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.accentColor.opacity(0.3), radius: 8, y: 4)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 48)
            }
        }
    }
    
    private func pageView(for page: OnboardingPage) -> some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon with gradient background circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: page.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: page.gradient.first?.opacity(0.4) ?? .clear, radius: 20, y: 10)
                
                Image(systemName: page.icon)
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(.white)
            }
            .padding(.bottom, 16)
            
            // Title
            Text(page.title)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            // Description
            Text(page.description)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .lineSpacing(2)
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Data Model

private struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let gradient: [Color]
}

#Preview {
    AppOnboardingView()
        .environmentObject(GuestSessionManager())
}
