import SwiftUI

struct InnerShadow: ViewModifier {
    var color: Color
    var radius: CGFloat
    var offset: CGPoint
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Color.white
                    .mask(
                        Rectangle()
                            .fill(
                                LinearGradient(gradient:
                                    Gradient(colors: [Color.black, Color.clear]),
                                    startPoint: .top, endPoint: .bottom)
                            )
                            .blur(radius: radius)
                            .offset(x: offset.x, y: offset.y)
                    )
                    .blendMode(.overlay)
            )
            .overlay(
                Rectangle()
                    .fill(color)
                    .mask(
                        Rectangle()
                            .fill(
                                LinearGradient(gradient:
                                    Gradient(colors: [Color.clear, Color.black]),
                                    startPoint: .top, endPoint: .bottom)
                            )
                            .blur(radius: radius)
                            .offset(x: offset.x, y: offset.y)
                    )
                    .blendMode(.overlay)
            )
    }
}

extension View {
    func innerShadow(color: Color, radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) -> some View {
        self.modifier(InnerShadow(color: color, radius: radius, offset: CGPoint(x: x, y: y)))
    }
}
