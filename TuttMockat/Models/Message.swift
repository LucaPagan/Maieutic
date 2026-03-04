import Foundation

struct Message: Identifiable, Equatable, Codable {
    var id = UUID()
    let text: String
    let isUser: Bool
    var date: Date = Date()
}
