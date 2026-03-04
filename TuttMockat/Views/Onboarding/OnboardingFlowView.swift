import SwiftUI

struct OnboardingFlowView: View {
    @Binding var profile: CalibrationProfile
    @Binding var isComplete: Bool
    
    @State private var currentStep: Int = 1
    
    var body: some View {
        VStack(spacing: 24) {
            
            ProgressView(value: Double(currentStep), total: 5.0)
                .tint(.teal)
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .accessibilityLabel("Step \\(currentStep) of 5")
            
            Text("Calibration Protocol")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.teal)
            
            TabView(selection: $currentStep) {
                SelectionStepView(title: "In which macro-area do you feel most dependent on AI?", options: OnboardingData.domains, selection: $profile.domain) {
                    withAnimation { currentStep = 2 }
                }.tag(1)
                
                SelectionStepView(title: "Which specific field of \\(profile.domain) do you want to rehabilitate?", options: OnboardingData.subDomains[profile.domain] ?? [], selection: $profile.subDomain) {
                    withAnimation { currentStep = 3 }
                }.tag(2)
                
                SelectionStepView(title: "What is your main cognitive block?", options: OnboardingData.getWeaknesses(for: profile.subDomain), selection: $profile.specificWeakness) {
                    withAnimation { currentStep = 4 }
                }.tag(3)
                
                SelectionStepView(title: "How often do you rely on AI for this task?", options: OnboardingData.dependencyLevels, selection: $profile.dependencyLevel) {
                    withAnimation { currentStep = 5 }
                }.tag(4)
                
                SelectionStepView(title: "How confident are you doing this without AI?", options: OnboardingData.confidenceLevels, selection: $profile.confidenceLevel) {
                    withAnimation { isComplete = true }
                }.tag(5)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentStep)
            
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
    }
}

