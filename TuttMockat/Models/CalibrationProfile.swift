import Foundation

struct CalibrationProfile: Codable, Equatable {
    var domain: String = ""
    var subDomain: String = ""
    var specificWeakness: String = ""
    var dependencyLevel: String = ""
    var confidenceLevel: String = ""
    
    var isComplete: Bool {
        !domain.isEmpty && !subDomain.isEmpty && !specificWeakness.isEmpty && !dependencyLevel.isEmpty && !confidenceLevel.isEmpty
    }
}
