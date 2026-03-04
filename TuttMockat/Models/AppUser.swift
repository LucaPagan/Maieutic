import Foundation
import SwiftData

@Model
class AppUser {
    @Attribute(.unique) var appleUserId: String
    var firstName: String?
    var lastName: String?
    var email: String?
    var nickname: String?
    
    init(appleUserId: String, firstName: String? = nil, lastName: String? = nil, email: String? = nil, nickname: String? = nil) {
        self.appleUserId = appleUserId
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.nickname = nickname
    }
}
