import Foundation
import SwiftData

@Model
class AppUser {
    @Attribute(.unique) var appleUserId: String
    var firstName: String?
    var lastName: String?
    var email: String?
    var hasSeenWelcome: Bool
    
    init(appleUserId: String, firstName: String? = nil, lastName: String? = nil, email: String? = nil, hasSeenWelcome: Bool = false) {
        self.appleUserId = appleUserId
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.hasSeenWelcome = hasSeenWelcome
    }
}
