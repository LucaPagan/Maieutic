import Foundation

enum SocraticPhase: Int, Codable, Equatable, CaseIterable {
    case phase1_xRay = 1        // 100% assistance
    case phase2_scaffold = 2    // 60% assistance
    case phase3_navigator = 3   // 30% assistance
    case phase4_pure = 4        // 0% assistance
}

struct CalibrationProfile: Codable, Equatable {
    var domain: String = ""
    var subDomain: String = ""
    var specificWeakness: String = ""
    var dependencyLevel: String = ""
    var confidenceLevel: String = ""
    var currentPhase: SocraticPhase = .phase1_xRay
    
    var isComplete: Bool {
        !domain.isEmpty && !subDomain.isEmpty && !specificWeakness.isEmpty && !dependencyLevel.isEmpty && !confidenceLevel.isEmpty
    }
}
