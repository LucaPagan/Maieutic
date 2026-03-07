import SwiftUI

struct ChatToolbar: ToolbarContent {
    let onToggleSidebar: () -> Void
    let onNewChat: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: onToggleSidebar) {
                Image(systemName: "sidebar.left")
                    .font(.system(size: 16, weight: .medium))
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button(action: onNewChat) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 16, weight: .medium))
            }
        }
    }
}
