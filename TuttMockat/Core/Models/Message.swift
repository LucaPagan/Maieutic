import Foundation
import SwiftData

@Model
final class Message: Identifiable, Equatable {
    var id: UUID = UUID()
    var text: String = ""
    var isUser: Bool = false
    var date: Date = Date()
    @Relationship(inverse: \ChatThread.messages) var thread: ChatThread?

    init(id: UUID = UUID(), text: String, isUser: Bool, date: Date = Date()) {
        self.id = id
        self.text = text
        self.isUser = isUser
        self.date = date
    }

    // Custom Equatable implementation for @Model class
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
}
