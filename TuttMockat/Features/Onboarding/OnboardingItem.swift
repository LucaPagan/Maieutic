import SwiftUI

struct OnboardingItem: Identifiable {
    var id: Int
    var title: String
    var subtitle: String
    var screenshot: UIImage?
    var videoName: String?
    var iconName: String?
    var showMockup: Bool = true
    var zoomScale: CGFloat = 1
    var zoomAnchor: UnitPoint = .center
}
