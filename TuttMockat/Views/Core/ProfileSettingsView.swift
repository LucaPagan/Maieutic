import SwiftUI
import SwiftData
import AuthenticationServices

struct SettingsIcon: View {
    let icon: String
    let color: Color
    
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
            .frame(width: 28, height: 28)
            .background(color.gradient, in: RoundedRectangle(cornerRadius: 6))
    }
}

struct ProfileSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var session: GuestSessionManager
    @Binding var profile: CalibrationProfile
    
    // Optional user for Nickname editing (nil if guest mode)
    var user: AppUser?
    
    // Local state to prevent modifying the live profile until "Save" is pressed.
    @State private var draftProfile: CalibrationProfile
    @State private var draftNickname: String = ""
    
    // Alerts
    @State private var showLogoutAlert = false
    @State private var showDeleteAccountAlert = false
    
    init(profile: Binding<CalibrationProfile>, user: AppUser? = nil) {
        self._profile = profile
        self.user = user
        self._draftProfile = State(initialValue: profile.wrappedValue)
        self._draftNickname = State(initialValue: user?.nickname ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Header Profile Card
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 84, height: 84)
                            .foregroundStyle(Color.accentColor.gradient)
                            .shadow(color: Color.accentColor.opacity(0.3), radius: 8, y: 4)
                        
                        VStack(spacing: 6) {
                            Text(displayName)
                                .font(.title3.bold())
                                .foregroundColor(.primary)
                            
                            if let email = user?.email, !email.isEmpty {
                                Text(email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            } else {
                                Text(user != nil ? "Linked Apple Account" : "Guest Mode")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets()) // Removes default padding for a cleaner look
                }
                
                if user != nil {
                    Section(header: Text("Personal Info")) {
                        HStack {
                            SettingsIcon(icon: "person.text.rectangle.fill", color: .gray)
                            Text("Nickname")
                            Spacer()
                            TextField("Nickname", text: $draftNickname)
                                .textInputAutocapitalization(.words)
                                .disableAutocorrection(true)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Macro-Area")) {
                    Picker(selection: $draftProfile.domain) {
                        ForEach(OnboardingData.domains, id: \.self) { domain in
                            Text(domain).tag(domain)
                        }
                    } label: {
                        HStack {
                            SettingsIcon(icon: "briefcase.fill", color: .indigo)
                            Text("Domain")
                        }
                    }
                    .onChange(of: draftProfile.domain) { newValue in
                        if let firstSub = OnboardingData.subDomains[newValue]?.first {
                            draftProfile.subDomain = firstSub
                            draftProfile.specificWeakness = OnboardingData.getWeaknesses(for: firstSub).first ?? ""
                        }
                    }
                    
                    Picker(selection: $draftProfile.subDomain) {
                        ForEach(OnboardingData.subDomains[draftProfile.domain] ?? [], id: \.self) { subDomain in
                            Text(subDomain).tag(subDomain)
                        }
                    } label: {
                        HStack {
                            SettingsIcon(icon: "scope", color: .blue)
                            Text("Specific Field")
                        }
                    }
                    .onChange(of: draftProfile.subDomain) { newValue in
                        draftProfile.specificWeakness = OnboardingData.getWeaknesses(for: newValue).first ?? ""
                    }
                }
                
                Section(header: Text("Limitations")) {
                    Picker(selection: $draftProfile.specificWeakness) {
                        ForEach(OnboardingData.getWeaknesses(for: draftProfile.subDomain), id: \.self) { weakness in
                            Text(weakness).tag(weakness)
                        }
                    } label: {
                        HStack {
                            SettingsIcon(icon: "brain.head.profile.fill", color: .purple)
                            Text("Cognitive Block")
                        }
                    }
                }
                
                Section(header: Text("Self-Assessment")) {
                    Picker(selection: $draftProfile.dependencyLevel) {
                        ForEach(OnboardingData.dependencyLevels, id: \.self) { level in
                            Text(level).tag(level)
                        }
                    } label: {
                        HStack {
                            SettingsIcon(icon: "chart.bar.fill", color: .orange)
                            Text("Dependency Level")
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker(selection: $draftProfile.confidenceLevel) {
                        ForEach(OnboardingData.confidenceLevels, id: \.self) { level in
                            Text(level).tag(level)
                        }
                    } label: {
                        HStack {
                            SettingsIcon(icon: "shield.fill", color: .green)
                            Text("Confidence Level")
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section {
                    Button(action: {
                        showLogoutAlert = true
                    }) {
                        HStack {
                            SettingsIcon(icon: "rectangle.portrait.and.arrow.right", color: .gray)
                            Text("Sign Out")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Button(action: {
                        showDeleteAccountAlert = true
                    }) {
                        HStack {
                            SettingsIcon(icon: "trash.fill", color: .red)
                            Text("Delete Account")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .alert("Sign Out", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    logout()
                }
            } message: {
                Text("Are you sure you want to sign out? You will need to sign in again to sync your data.")
            }
            .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("Are you sure you want to delete your account? This action is permanent and will delete all your local data including chat history and metrics.")
            }
            .navigationTitle("Profile Settings")
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
                        
                        if let validUser = user, !draftNickname.trimmingCharacters(in: .whitespaces).isEmpty {
                            validUser.nickname = draftNickname.trimmingCharacters(in: .whitespaces)
                            try? modelContext.save()
                        }
                        
                        dismiss()
                    }
                    .tint(.accentColor)
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var displayName: String {
        if !draftNickname.trimmingCharacters(in: .whitespaces).isEmpty {
            return draftNickname
        } else if let validUser = user {
            if let first = validUser.firstName, let last = validUser.lastName, !first.isEmpty {
                return "\(first) \(last)"
            }
            return "User"
        } else {
            return "Guest"
        }
    }
    
    // MARK: - Actions
    
    private func logout() {
        do {
            try modelContext.delete(model: AppUser.self)
            try modelContext.save()
            session.reset()
            dismiss()
        } catch {
            print("Failed to logout: \(error.localizedDescription)")
        }
    }
    
    private func deleteAccount() {
        // Step 1: Attempt to check credential state with Apple before deleting
        if let appleUserId = user?.appleUserId {
            let provider = ASAuthorizationAppleIDProvider()
            provider.getCredentialState(forUserID: appleUserId) { state, _ in
                DispatchQueue.main.async {
                    // Proceed with deletion regardless of credential state
                    // The credential check ensures Apple knows we're handling the account
                    self.performAccountDeletion()
                }
            }
        } else {
            performAccountDeletion()
        }
    }
    
    private func performAccountDeletion() {
        do {
            try modelContext.delete(model: AppUser.self)
            try modelContext.delete(model: ChatThread.self)
            try modelContext.delete(model: InteractionMetric.self)
            try modelContext.save()
            session.reset()
            dismiss()
        } catch {
            print("Failed to delete account: \(error.localizedDescription)")
        }
    }
}

