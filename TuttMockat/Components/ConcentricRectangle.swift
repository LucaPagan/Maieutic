import SwiftUI

struct ConcentricRectangle: Shape {
    enum Corners {
        case concentric
        case fixed(CGFloat)
    }

    var corners: Corners = .concentric
    var isUniform: Bool = false

    func path(in rect: CGRect) -> Path {
        let radius: CGFloat
        switch corners {
        case .concentric:
            radius = min(rect.width, rect.height) * 0.12
        case .fixed(let r):
            radius = r
        }
        return Path(roundedRect: rect, cornerRadius: radius, style: .continuous)
    }
}
