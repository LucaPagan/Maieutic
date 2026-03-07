import SwiftUI

struct CalibrationFlow: View {
    @Binding var profile: CalibrationProfile
    @Binding var isComplete: Bool
    @State private var currentStep = 1

    private let totalSteps = 5

    private var canContinue: Bool {
        switch currentStep {
        case 1: !profile.domain.isEmpty
        case 2: !profile.subDomain.isEmpty
        case 3: !profile.specificWeakness.isEmpty
        case 4: !profile.dependencyLevel.isEmpty
        case 5: !profile.confidenceLevel.isEmpty
        default: false
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            navBar
            progressBar

            ZStack {
                switch currentStep {
                case 1: step1.transition(slideTransition)
                case 2: step2.transition(slideTransition)
                case 3: step3.transition(slideTransition)
                case 4: step4.transition(slideTransition)
                case 5: step5.transition(slideTransition)
                default: EmptyView()
                }
            }
            .animation(.easeInOut(duration: 0.3), value: currentStep)

            continueButton
        }
        .background(Color(uiColor: .secondarySystemBackground))
    }

    // MARK: - Navigation

    private var navBar: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) { currentStep -= 1 }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .font(.system(.body, design: .rounded))
            }
            .opacity(currentStep > 1 ? 1 : 0)
            .disabled(currentStep <= 1)

            Spacer()

            Text("Step \(currentStep) of \(totalSteps)")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private var progressBar: some View {
        ProgressView(value: Double(currentStep), total: Double(totalSteps))
            .tint(.accentColor)
            .padding(.horizontal, 20)
            .animation(.easeInOut(duration: 0.3), value: currentStep)
    }

    private var continueButton: some View {
        Button { advanceOrComplete() } label: {
            Text(currentStep == totalSteps ? "Get Started" : "Continue")
                .font(.system(.headline, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .clipShape(Capsule())
        .disabled(!canContinue)
        .padding(.horizontal, 20)
        .padding(.bottom, 36)
    }

    // MARK: - Steps

    private var step1: some View {
        SelectionStepView(
            icon: "square.grid.2x2", title: "Choose Your Area",
            description: "Which area do you feel most dependent on AI?",
            options: OnboardingData.domains, selection: $profile.domain
        )
    }

    private var step2: some View {
        SelectionStepView(
            icon: "target", title: "Pick a Focus",
            description: "Which specific field of \(profile.domain) do you want to work on?",
            options: OnboardingData.subDomains[profile.domain] ?? [], selection: $profile.subDomain
        )
    }

    private var step3: some View {
        SelectionStepView(
            icon: "brain.head.profile", title: "Your Challenge",
            description: "What's your main cognitive block in \(profile.subDomain)?",
            options: OnboardingData.getWeaknesses(for: profile.subDomain), selection: $profile.specificWeakness
        )
    }

    private var step4: some View {
        SelectionStepView(
            icon: "gauge.with.needle", title: "AI Dependency",
            description: "How often do you rely on AI for this task?",
            options: OnboardingData.dependencyLevels, selection: $profile.dependencyLevel
        )
    }

    private var step5: some View {
        SelectionStepView(
            icon: "chart.bar.fill", title: "Your Confidence",
            description: "How confident are you doing this without AI?",
            options: OnboardingData.confidenceLevels, selection: $profile.confidenceLevel
        )
    }

    // MARK: - Logic

    private func advanceOrComplete() {
        if currentStep == totalSteps {
            withAnimation(.easeInOut(duration: 0.3)) { isComplete = true }
        } else {
            clearDownstreamSelections()
            withAnimation(.easeInOut(duration: 0.3)) { currentStep += 1 }
        }
    }

    private func clearDownstreamSelections() {
        switch currentStep {
        case 1:
            profile.subDomain = ""
            profile.specificWeakness = ""
        case 2:
            profile.specificWeakness = ""
        default: break
        }
    }

    private var slideTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}
