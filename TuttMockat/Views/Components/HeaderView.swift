import SwiftUI

struct HeaderView: View {
    let status: String
    var onMenuTap: () -> Void
    var onProfileTap: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onMenuTap) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
            }
            .padding(.trailing, 8)
            
            VStack(alignment: .leading) {
                Text("CogniGuard")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                Text(status)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(status.contains("Error") ? .red : .teal)
            }
            Spacer()
            
            Button(action: onProfileTap) {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 24))
                    .foregroundColor(.teal)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 5)
    }
}
