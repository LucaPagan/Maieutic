import Foundation
import SwiftData

@Model
class InteractionMetric: Identifiable {
    var id: UUID = UUID()
    var date: Date = Date()
    var dependencyScore: Int = 0
    var userMessagePreview: String = ""

    init(date: Date = Date(), dependencyScore: Int, userMessagePreview: String) {
        self.id = UUID()
        self.date = date
        self.dependencyScore = min(max(dependencyScore, 0), 100)
        self.userMessagePreview = userMessagePreview
    }
}
