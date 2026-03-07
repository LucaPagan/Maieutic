import SwiftUI
import SwiftData
import Combine
import AuthenticationServices

struct ProfileSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var authManager: AuthenticationManager
    @Binding var profile: CalibrationProfile

    var user: AppUser?

    @State private var draftProfile: CalibrationProfile
    @State private var draftNickname: String
    @State private var showLogoutConfirmation = false
    @State private var showDeleteConfirmation = false

    init(profile: Binding<CalibrationProfile>, user: AppUser? = nil) {
        _profile = profile
        self.user = user
        _draftProfile = State(initialValue: profile.wrappedValue)
        _draftNickname = State(initialValue: user?.nickname ?? user?.firstName ?? "")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    SettingsAccountHeader(
                        nickname: $draftNickname,
                        isGuestMode: authManager.isGuestMode,
                        email: user?.email
                    )

                    learningProfileSection
                    selfAssessmentSection
                    accountActionsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(Color(uiColor: .secondarySystemBackground))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .font(.headline)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .alert("Sign Out", isPresented: $showLogoutConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) { logout() }
        } message: {
            Text("You'll need to sign in again to access your conversations.")
        }
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { deleteAccount() }
        } message: {
            Text("This permanently deletes all your data, conversations, and progress.")
        }
    }

    // MARK: - Sections

    private var learningProfileSection: some View {
        SettingsSectionCard("Learning Profile") {
            SettingsPickerRow(icon: "briefcase.fill", label: "Domain", selection: $draftProfile.domain, options: OnboardingData.domains)
                .onChange(of: draftProfile.domain) {
                    if let firstSub = OnboardingData.subDomains[draftProfile.domain]?.first {
                        draftProfile.subDomain = firstSub
                        draftProfile.specificWeakness = OnboardingData.getWeaknesses(for: firstSub).first ?? ""
                    }
                }
            sectionDivider
            SettingsPickerRow(icon: "scope", label: "Field", selection: $draftProfile.subDomain, options: OnboardingData.subDomains[draftProfile.domain] ?? [])
                .onChange(of: draftProfile.subDomain) {
                    draftProfile.specificWeakness = OnboardingData.getWeaknesses(for: draftProfile.subDomain).first ?? ""
                }
            sectionDivider
            SettingsPickerRow(icon: "brain.head.profile.fill", label: "Cognitive Block", selection: $draftProfile.specificWeakness, options: OnboardingData.getWeaknesses(for: draftProfile.subDomain))
        }
    }

    private var selfAssessmentSection: some View {
        SettingsSectionCard("Self-Assessment") {
            SettingsPickerRow(icon: "chart.bar.fill", label: "Dependency", selection: $draftProfile.dependencyLevel, options: OnboardingData.dependencyLevels)
            sectionDivider
            SettingsPickerRow(icon: "shield.fill", label: "Confidence", selection: $draftProfile.confidenceLevel, options: OnboardingData.confidenceLevels)
        }
    }

    private var accountActionsSection: some View {
        VStack(spacing: 0) {
            Button { showLogoutConfirmation = true } label: {
                HStack(spacing: 12) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.body).frame(width: 24, alignment: .center)
                    Text("Sign Out").font(.body)
                    Spacer()
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }

            sectionDivider

            Button { showDeleteConfirmation = true } label: {
                HStack(spacing: 12) {
                    Image(systemName: "trash")
                        .font(.body).frame(width: 24, alignment: .center)
                    Text("Delete Account").font(.body)
                    Spacer()
                }
                .foregroundStyle(.red)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
    }

    private var sectionDivider: some View {
        Rectangle()
            .fill(Color(uiColor: .separator))
            .frame(height: 0.5)
            .padding(.leading, 52)
    }

    // MARK: - Actions

    private func save() {
        profile = draftProfile
        authManager.saveProfile()
        if let validUser = user {
            let trimmed = draftNickname.trimmingCharacters(in: .whitespaces)
            validUser.nickname = trimmed.isEmpty ? nil : trimmed
            try? modelContext.save()
        }
        dismiss()
    }

    private func logout() {
        do {
            try modelContext.delete(model: AppUser.self)
            try modelContext.save()
            authManager.signOut()
            dismiss()
        } catch {
            print("Logout failed: \(error.localizedDescription)")
        }
    }

    private func deleteAccount() {
        guard !authManager.isGuestMode else {
            finalizeDeletion()
            return
        }
        
        // Per revocare il token Apple, serve riautenticare l'utente per ottenere un authorization code fresco.
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        let delegate = AccountDeletionDelegate(authManager: authManager, modelContext: modelContext, dismiss: dismiss)
        
        // Manteniamo una reference forte al delegate affinché non venga deallocato prematuramente
        objc_setAssociatedObject(controller, "AccountDeletionDelegate", delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        controller.delegate = delegate
        controller.presentationContextProvider = delegate
        controller.performRequests()
    }
    
    private func finalizeDeletion() {
        do {
            try modelContext.delete(model: AppUser.self)
            try modelContext.delete(model: ChatThread.self)
            try modelContext.delete(model: InteractionMetric.self)
            try modelContext.save()
            authManager.reset()
            dismiss()
        } catch {
            print("Account deletion failed: \(error.localizedDescription)")
        }
    }
}

// MARK: - Account Deletion Delegate

private class AccountDeletionDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    let authManager: AuthenticationManager
    let modelContext: ModelContext
    let dismiss: DismissAction
    
    init(authManager: AuthenticationManager, modelContext: ModelContext, dismiss: DismissAction) {
        self.authManager = authManager
        self.modelContext = modelContext
        self.dismiss = dismiss
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return ASPresentationAnchor()
        }
        return window
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task {
            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
               let authorizationCodeData = credential.authorizationCode,
               let authorizationCode = String(data: authorizationCodeData, encoding: .utf8) {
                
                // NOTA: Qui dovresti chiamare il tuo backend passando `authorizationCode`
                // Il backend scambierà il codice con un access token e lancerà la revoke a Apple.
                // Poiché in questo momento non abbiamo un backend configurato, stampiamo il codice a fini di audit
                // e procediamo con l'eliminazione locale dei dati affinché l'app funzioni.
                print("AUTHORIZATION CODE OBTANED FOR REVOCATION: \(authorizationCode)")
                print("TODO: Send this auth_code to backend to permanently revoke access token.")
                
                await finalizeDeletion()
            } else {
                await finalizeDeletion()
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple Sign In re-auth failed during deletion: \(error.localizedDescription)")
        // Procediamo comunque con l'eliminazione in locale
        Task {
            await finalizeDeletion()
        }
    }
    
    @MainActor
    private func finalizeDeletion() {
        do {
            try modelContext.delete(model: AppUser.self)
            try modelContext.delete(model: ChatThread.self)
            try modelContext.delete(model: InteractionMetric.self)
            try modelContext.save()
            authManager.reset()
            dismiss()
        } catch {
            print("Account deletion finalized with error: \(error.localizedDescription)")
        }
    }
}

// MARK: - Section Card

private struct SettingsSectionCard<Content: View>: View {
    let title: String
    let content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.leading, 4)

            VStack(spacing: 0) { content }
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
