import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func dismissKeyboardOnTap() -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { hideKeyboard() }
        )
    }

    func triggerHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}
