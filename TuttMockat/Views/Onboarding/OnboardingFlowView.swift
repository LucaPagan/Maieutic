import SwiftUI

struct OnboardingFlowView: View {
    @Binding var profile: CalibrationProfile
    @Binding var isComplete: Bool
    @Environment(\.colorScheme) private var colorScheme
    @State private var currentStep: Int = 1
    
    private let totalSteps = 5
    
    var body: some View {
        ZStack {
            // Background ignores safe area
            (colorScheme == .dark ? Color(white: 0.11) : Color(white: 0.96))
                .ignoresSafeArea()
            
            // Content DOES NOT ignore safe area, preventing collision with notch/dynamic island
            VStack(spacing: 0) {
                
                // Progress and Title Header
                VStack(spacing: 20) {
                    // Custom segmented progress indicator
                    HStack(spacing: 6) {
                        ForEach(1...totalSteps, id: \.self) { step in
                            Capsule()
                                .fill(step <= currentStep ? Color.accentColor : Color(.systemGray4))
                                .frame(height: 5)
                                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 16)
                    
                    Text("Calibration Protocol")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                }
                .padding(.bottom, 32)
                
                // Content Switcher
                ZStack {
                    if currentStep == 1 {
                        SelectionStepView(title: "In which macro-area do you feel most dependent on AI?", description: "This helps us tailor the interactions to your specific daily context.", options: OnboardingData.domains, selection: $profile.domain) {
                            advance()
                        }
                        .transition(slideTransition)
                    } else if currentStep == 2 {
                        SelectionStepView(title: "Which specific field of \(profile.domain) do you want to rehabilitate?", description: "Focusing on a specific area allows the Socratic Engine to ask more targeted and relevant questions.", options: OnboardingData.subDomains[profile.domain] ?? [], selection: $profile.subDomain) {
                            advance()
                        }
                        .transition(slideTransition)
                    } else if currentStep == 3 {
                        SelectionStepView(title: "What is your main cognitive block?", description: "Identifying your main block helps the AI determine how to best prompt your reasoning.", options: OnboardingData.getWeaknesses(for: profile.subDomain), selection: $profile.specificWeakness) {
                            advance()
                        }
                        .transition(slideTransition)
                    } else if currentStep == 4 {
                        SelectionStepView(title: "How often do you rely on AI for this task?", description: "This sets the initial level of assistance the Socratic Engine will provide in Phase 1.", options: OnboardingData.dependencyLevels, selection: $profile.dependencyLevel) {
                            advance()
                        }
                        .transition(slideTransition)
                    } else if currentStep == 5 {
                        SelectionStepView(title: "How confident are you doing this without AI?", description: "Your confidence level determines the pace at which the AI will reduce its scaffolding over time.", options: OnboardingData.confidenceLevels, selection: $profile.confidenceLevel) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                isComplete = true
                            }
                        }
                        .transition(slideTransition)
                    }
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.82), value: currentStep)
                
            }
        }
    }
    
    private func advance() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
            currentStep += 1
        }
    }
    
    private var slideTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}
