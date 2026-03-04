import SwiftUI

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.accentColor.gradient)
                .frame(width: 30)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.headline, design: .rounded))
                Text(description)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .accessibilityElement(children: .combine)
        }
    }
}
