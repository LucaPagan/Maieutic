import Foundation
import SwiftData

@Model
class InteractionMetric: Identifiable {
    var id: UUID
    var date: Date
    var dependencyScore: Int // 0 to 100
    var userMessagePreview: String
    
    // Optional back-reference if needed: var user: AppUser?
    
    init(date: Date = Date(), dependencyScore: Int, userMessagePreview: String) {
        self.id = UUID()
        self.date = date
        self.dependencyScore = dependencyScore
        self.userMessagePreview = userMessagePreview
    }
}
