import SwiftUI
import SwiftData
import Combine
import AuthenticationServices

struct AuthChoiceView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @State private var isLoading = false
    @State private var showError = false
    @State private var authError: String = ""
    @State private var currentNonce: String?

    var body: some View {
        ZStack {
            Color(uiColor: .secondarySystemBackground).ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(Color(uiColor: .label))
                    .frame(width: 100, height: 100)
                    .glassEffect(.regular, in: .circle)

                VStack(spacing: 12) {
                    Text("Almost There")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(uiColor: .label))

                    Text("Sign in to save your progress, sync chat history, and unlock all features.")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Spacer()

                VStack(spacing: 16) {
                    if isLoading {
                        ProgressView()
                            .frame(height: 54)
                    } else {
                        SignInWithAppleButton(.signIn) { request in
                            let nonce = CryptoHelper.randomNonceString()
                            currentNonce = nonce
                            request.requestedScopes = [.fullName, .email]
                            request.nonce = CryptoHelper.sha256(nonce)
                        } onCompletion: { result in
                            isLoading = true
                            Task {
                                if case .success(let authorization) = result {
                                    do {
                                        try await AppleSignInService.handleAuthorization(
                                            authorization,
                                            context: modelContext,
                                            authManager: authManager,
                                            nonce: currentNonce
                                        )
                                    } catch {
                                        authError = error.localizedDescription
                                        showError = true
                                    }
                                } else if case .failure(let error) = result {
                                    authError = error.localizedDescription
                                    showError = true
                                }
                                isLoading = false
                            }
                        }
                        // Adattivo: white su dark, black su light — HIG Apple
                        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                        .frame(height: 54)
                        .clipShape(RoundedRectangle(cornerRadius: 40))
                        .padding(.horizontal, 24)
                    }

                    Button {
                        authManager.enterGuestMode()
                    } label: {
                        Text("Continue without an account")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(Color(uiColor: .tertiaryLabel))
                    }
                    .padding(.top, 4)
                    .opacity(isLoading ? 0.5 : 1)
                    .disabled(isLoading)
                }

                Text("Your data stays on your device. We use Apple Intelligence for all AI processing.")
                    .font(.caption2)
                    .foregroundStyle(Color(uiColor: .quaternaryLabel))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
            }
        }
        .alert(isPresented: $showError) {
            Alert(
                title: Text("Sign In Error"),
                message: Text(authError),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
