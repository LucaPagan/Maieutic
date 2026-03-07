import Foundation
import SwiftData

@Model
class ChatThread {
    var id: UUID = UUID()
    var title: String = ""
    var domain: String = ""
    var date: Date = Date()
    @Relationship(deleteRule: .cascade) var messages: [Message]? = []

    init(id: UUID = UUID(), title: String, domain: String, date: Date = Date(), messages: [Message] = []) {
        self.id = id
        self.title = title
        self.domain = domain
        self.date = date
        self.messages = messages
    }
}
