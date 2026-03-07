import SwiftUI
import Combine

struct OnboardingCarousel: View {
    @EnvironmentObject private var authManager: AuthenticationManager

    var tint: Color = .accentColor
    var hideBezels: Bool = false

    @State private var currentIndex = 0
    @State private var screenshotSize: CGSize = .zero
    @State private var bounceZoom: Bool = false

    private let items: [OnboardingItem] = [
        .init(id: 0, title: "Welcome to Maieutic", subtitle: "Your AI companion for\nmeaningful conversations", screenshot: nil, videoName: nil, iconName: "sparkles", showMockup: false, zoomScale: 2.4, zoomAnchor: .center),
        .init(id: 1, title: "Socratic Engine", subtitle: "We calibrate to understand you better\nthrough a quick initial setup.", screenshot: nil, videoName: "calibration_intro", iconName: nil, showMockup: true),
        .init(id: 2, title: "Your Personal Chatbot", subtitle: "Have deep, insightful\nconversations anytime.", screenshot: UIImage(named: "chatbot_mockup"), videoName: nil, iconName: nil, showMockup: true, zoomAnchor: UnitPoint(x: 0.5, y: 0.85)),
        .init(id: 3, title: "Track Your Progress", subtitle: "Review your statistics\nand personal growth.", screenshot: UIImage(named: "stats_mockup"), videoName: nil, iconName: nil, showMockup: true),
    ]

    private var deviceCornerRadius: CGFloat {
        let imageSize = items.compactMap { $0.screenshot }.first?.size ?? CGSize(width: 1179, height: 2556)
        if imageSize.height == 0 { return 0 }
        return 180 * (screenshotSize.height / imageSize.height)
    }

    private var animation: Animation {
        .interpolatingSpring(duration: 0.65, bounce: 0, initialVelocity: 0)
    }

    // Padding condiviso per tenere back e skip perfettamente allineati
    private let navTopPadding: CGFloat = 5
    private let navHorizontalPadding: CGFloat = 15

    var body: some View {
        ZStack(alignment: .top) {
            Color(uiColor: .secondarySystemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                screenshotContent
                    .compositingGroup()
                    .scaleEffect(
                        items[currentIndex].zoomScale * (bounceZoom && currentIndex == 2 ? 1.5 : 1.0),
                        anchor: items[currentIndex].zoomAnchor
                    )
                    .offset(y: bounceZoom && currentIndex == 2 ? -80 : 0)
                    .padding(.top, 70)
                    .padding(.horizontal, 75)
                    .padding(.bottom, 20)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                VStack(spacing: 10) {
                    textContent
                    pageIndicator
                    continueButton
                }
                .padding(.top, 25)
                .padding(.horizontal, 15)
                .padding(.bottom, 30)
                .frame(height: 220)
                .background { bottomBarBackground }
            }
            .ignoresSafeArea(edges: .bottom)

            // Back e Skip condividono esattamente gli stessi padding top e horizontal
            backButton
                .opacity(currentIndex > 0 ? 1 : 0)
                .animation(animation, value: currentIndex)

            skipButton
                .opacity(currentIndex < items.count - 1 ? 1 : 0)
                .animation(animation, value: currentIndex)
        }
        .onChange(of: currentIndex) { newValue in
            if newValue == 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.easeInOut(duration: 1.0)) { bounceZoom = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation(.easeInOut(duration: 1.0)) { bounceZoom = false }
                    }
                }
            } else {
                bounceZoom = false
            }
        }
        .gesture(swipeGesture)
    }

    // MARK: - Screenshot

    @ViewBuilder
    private var screenshotContent: some View {
        let shape = ConcentricRectangle(corners: .concentric, isUniform: true)

        GeometryReader { geo in
            Rectangle().fill(Color(uiColor: .secondarySystemBackground))

            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(items.indices, id: \.self) { index in
                        Group {
                            if let screenshot = items[index].screenshot {
                                Image(uiImage: screenshot)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } else if let video = items[index].videoName {
                                LoopingVideoPlayerView(videoName: video)
                                    .aspectRatio(1179/2556, contentMode: .fit)
                            } else if let icon = items[index].iconName {
                                ZStack {
                                    Color(uiColor: .secondarySystemBackground)
                                    Image(systemName: icon)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 120, height: 120)
                                        .foregroundStyle(tint)
                                        .symbolEffect(.breathe)
                                }
                                .aspectRatio(1179/2556, contentMode: .fit)
                            } else {
                                Rectangle().fill(Color(uiColor: .secondarySystemBackground))
                                    .aspectRatio(1179/2556, contentMode: .fit)
                            }
                        }
                        .onGeometryChange(for: CGSize.self) { $0.size } action: { newValue in
                            if screenshotSize == .zero { screenshotSize = newValue }
                        }
                        .clipShape(shape)
                        .frame(width: geo.size.width, height: geo.size.height)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollDisabled(true)
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .scrollPosition(id: .init(get: { currentIndex }, set: { _ in }))
        }
        .clipShape(shape)
        .overlay {
            if screenshotSize != .zero, !hideBezels {
                Group {
                    if let mockupImage = UIImage(named: "iPhoneMockup") {
                        Image(uiImage: mockupImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .allowsHitTesting(false)
                    } else {
                        ZStack {
                            shape.stroke(Color(uiColor: .separator), lineWidth: 10)
                            shape.stroke(Color(uiColor: .opaqueSeparator), lineWidth: 2).padding(-4)
                            shape.stroke(Color(uiColor: .secondarySystemBackground), lineWidth: 2).padding(-5)

                            if items[currentIndex].videoName == nil {
                                Capsule()
                                    .fill(Color(uiColor: .black))
                                    .frame(width: screenshotSize.width * 0.32, height: screenshotSize.width * 0.08)
                                    .padding(.top, screenshotSize.width * 0.05)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            }
                        }
                        .padding(-5)
                    }
                }
                .opacity(items[currentIndex].showMockup ? 1 : 0)
                .animation(animation, value: currentIndex)
            }
        }
        .frame(
            maxWidth: screenshotSize.width == 0 ? nil : screenshotSize.width,
            maxHeight: screenshotSize.height == 0 ? nil : screenshotSize.height
        )
        .containerShape(RoundedRectangle(cornerRadius: deviceCornerRadius))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Text

    @ViewBuilder
    private var textContent: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(items.indices, id: \.self) { index in
                    let isActive = currentIndex == index
                    VStack(spacing: 6) {
                        Text(items[index].title)
                            .font(.title2).fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .foregroundStyle(Color(uiColor: .label))

                        Text(items[index].subtitle)
                            .font(.callout)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                    }
                    .frame(width: geo.size.width, alignment: .center)
                    .compositingGroup()
                    .blur(radius: isActive ? 0 : 30)
                    .opacity(isActive ? 1 : 0)
                    .animation(animation, value: currentIndex)
                }
            }
        }
    }

    // MARK: - Controls

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(items.indices, id: \.self) { index in
                Capsule()
                    .fill(Color(uiColor: currentIndex == index ? .label : .tertiaryLabel))
                    .frame(width: currentIndex == index ? 25 : 6, height: 6)
            }
        }
        .padding(.bottom, 5)
    }

    private var continueButton: some View {
        Button {
            if currentIndex == items.count - 1 { authManager.completeIntroOnboarding() }
            withAnimation(animation) { currentIndex = min(currentIndex + 1, items.count - 1) }
        } label: {
            Text(currentIndex == items.count - 1 ? "Get Started" : "Continue")
                .fontWeight(.medium)
                .contentTransition(.numericText())
                .padding(.vertical, 6)
        }
        .tint(tint)
        .buttonStyle(.glassProminent)
        .buttonSizing(.flexible)
        .padding(.horizontal, 30)
    }

    // MARK: - Nav Buttons (allineati con stessi padding)

    private var backButton: some View {
        Button {
            withAnimation(animation) { currentIndex = max(currentIndex - 1, 0) }
        } label: {
            Image(systemName: "chevron.left")
                .font(.title3)
                .frame(width: 20, height: 30)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.leading, navHorizontalPadding)
        .padding(.top, navTopPadding)
    }

    private var skipButton: some View {
        Button { authManager.completeIntroOnboarding() } label: {
            Text("Skip")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                // Stessa altezza hit-area del backButton per allineamento visivo preciso
                .frame(height: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .padding(.trailing, navHorizontalPadding)
        .padding(.top, navTopPadding)
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 30)
            .onEnded { value in
                withAnimation(animation) {
                    if value.translation.width < -50 {
                        if currentIndex == items.count - 1 { authManager.completeIntroOnboarding() }
                        currentIndex = min(currentIndex + 1, items.count - 1)
                    } else if value.translation.width > 50 {
                        currentIndex = max(currentIndex - 1, 0)
                    }
                }
            }
    }

    @ViewBuilder
    private var bottomBarBackground: some View {
        if items[currentIndex].zoomScale > 1 {
            Rectangle()
                .fill(Color(uiColor: .secondarySystemBackground).opacity(0.5))
                .glassEffect(.clear, in: .rect)
                .blur(radius: 15)
                .padding([.horizontal, .bottom], -30)
                .padding(.top, -7.5)
                .ignoresSafeArea()
        } else {
            Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
        }
    }
}

#Preview("Dark") {
    OnboardingCarousel()
        .environmentObject(AuthenticationManager())
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    OnboardingCarousel()
        .environmentObject(AuthenticationManager())
        .preferredColorScheme(.light)
}
