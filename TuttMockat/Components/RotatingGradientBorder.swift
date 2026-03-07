import SwiftUI

struct RotatingGradientBorder: View {
    var cornerRadius: CGFloat
    var color: Color = .accentColor
    var lineWidth: CGFloat = 3.5
    var duration: Double = 2.5

    @State private var isAnimating = false

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius)
    }

    var body: some View {
        shape
            .stroke(
                color.gradient,
                style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
            )
            .mask {
                let clearColors: [Color] = Array(repeating: .clear, count: 3)
                shape.fill(
                    AngularGradient(
                        colors: clearColors + [.white] + clearColors,
                        center: .center,
                        angle: .init(degrees: isAnimating ? 360 : 0)
                    )
                )
                .animation(
                    .linear(duration: duration).repeatForever(autoreverses: false),
                    value: isAnimating
                )
            }
            .padding(-1.25)
            .blur(radius: 1.5)
            .onAppear { isAnimating = true }
            .onDisappear { isAnimating = false }
    }
}
