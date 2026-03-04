import SwiftUI

struct ProfileSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var profile: CalibrationProfile
    
    // Local state to prevent modifying the live profile until "Save" is pressed.
    // If we want instant updates, we can just bind directly. We'll do a local copy for saving.
    @State private var draftProfile: CalibrationProfile
    
    init(profile: Binding<CalibrationProfile>) {
        self._profile = profile
        self._draftProfile = State(initialValue: profile.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Macro-Area")) {
                    Picker("Domain", selection: $draftProfile.domain) {
                        ForEach(OnboardingData.domains, id: \.self) { domain in
                            Text(domain).tag(domain)
                        }
                    }
                    .onChange(of: draftProfile.domain) { newValue in
                        // Reset sub-domain and weakness if domain changes
                        if let firstSub = OnboardingData.subDomains[newValue]?.first {
                            draftProfile.subDomain = firstSub
                            draftProfile.specificWeakness = OnboardingData.getWeaknesses(for: firstSub).first ?? ""
                        }
                    }
                }
                
                Section(header: Text("Specific Field")) {
                    Picker("Sub-Domain", selection: $draftProfile.subDomain) {
                        ForEach(OnboardingData.subDomains[draftProfile.domain] ?? [], id: \.self) { subDomain in
                            Text(subDomain).tag(subDomain)
                        }
                    }
                    .onChange(of: draftProfile.subDomain) { newValue in
                        draftProfile.specificWeakness = OnboardingData.getWeaknesses(for: newValue).first ?? ""
                    }
                }
                
                Section(header: Text("Cognitive Block")) {
                    Picker("Weakness", selection: $draftProfile.specificWeakness) {
                        ForEach(OnboardingData.getWeaknesses(for: draftProfile.subDomain), id: \.self) { weakness in
                            Text(weakness).tag(weakness)
                        }
                    }
                }
                
                Section(header: Text("Dependency Level")) {
                    Picker("Dependency", selection: $draftProfile.dependencyLevel) {
                        ForEach(OnboardingData.dependencyLevels, id: \.self) { level in
                            Text(level).tag(level)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Confidence Level")) {
                    Picker("Confidence", selection: $draftProfile.confidenceLevel) {
                        ForEach(OnboardingData.confidenceLevels, id: \.self) { level in
                            Text(level).tag(level)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("Calibration Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        profile = draftProfile
                        dismiss()
                    }
                    .tint(.teal)
                    .fontWeight(.bold)
                }
            }
        }
    }
}
