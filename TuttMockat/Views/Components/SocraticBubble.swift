import SwiftUI

struct SocraticBubble: View {
    let message: Message
    
    var body: some View {
        HStack(alignment: .bottom) {
            if message.isUser { Spacer() }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                FormattedMessageView(text: message.text, isUser: message.isUser)
                    .padding(16)
                    .background(message.isUser ? Color.accentColor : Color(.systemGray5))
                    .cornerRadius(18, corners: message.isUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                
                Text(message.date, style: .time)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(message.isUser ? "You said: \\(message.text)" : "Architect said: \\(message.text)")
            
            if !message.isUser { Spacer() }
        }
        .padding(.horizontal, 16)
    }
}
