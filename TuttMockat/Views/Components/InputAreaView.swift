import SwiftUI

struct InputAreaView: View {
    @Binding var text: String
    let isEnabled: Bool // Gestione dello stato di attivazione per UX
    let onSend: () -> Void
    let onAccessoryTap: () -> Void
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            
            Button(action: onAccessoryTap) {
                Image(systemName: "paperclip")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(isEnabled ? .white : .gray)
            }
            .frame(width: 44, height: 44)
            .background(Color.black.opacity(0.4).background(.ultraThinMaterial))
            .clipShape(Circle())
            .padding(.bottom, 2)
            .disabled(!isEnabled)
            .accessibilityLabel("Attach file")
            .accessibilityHint("Feature disabled in current protocol")
            
            HStack(alignment: .bottom, spacing: 0) {
                TextField(isEnabled ? "Message" : "Model Unavailable...", text: $text, axis: .vertical)
                    .lineLimit(1...5)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.leading, 16)
                    .disabled(!isEnabled)
                    .accessibilityLabel("Message input field")
                
                Button(action: onAccessoryTap) {
                    Image(systemName: "moon")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor((isEnabled ? Color.white : Color.gray).opacity(0.7))
                }
                .padding(.bottom, 12)
                .padding(.trailing, 16)
                .padding(.leading, 8)
                .disabled(!isEnabled)
                .accessibilityLabel("Stickers and Extras")
            }
            .background(Color.black.opacity(0.4).background(.ultraThinMaterial))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            
            Button(action: {
                if !text.isEmpty {
                    onSend()
                } else {
                    onAccessoryTap()
                }
            }) {
                ZStack {
                    if text.isEmpty {
                        Image(systemName: "mic")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundColor(isEnabled ? .white : .gray)
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.teal)
                            .clipShape(Circle())
                    }
                }
                .frame(width: 44, height: 44)
            }
            .background(Color.black.opacity(0.4).background(.ultraThinMaterial))
            .clipShape(Circle())
            .padding(.bottom, 2)
            .disabled(!isEnabled)
            .accessibilityLabel(text.isEmpty ? "Record Voice Message" : "Send Message")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.clear)
        // Diminuisce l'opacità per far capire graficamente all'utente che l'app è in stato di blocco (es. device non supportato)
        .opacity(isEnabled ? 1.0 : 0.5)
    }
}
