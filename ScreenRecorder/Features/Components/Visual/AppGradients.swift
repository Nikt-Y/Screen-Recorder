import SwiftUI

struct AppGradients {
    static var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(hex: "FB6448"), location: 0),
                .init(color: Color(hex: "FC0959"), location: 1)
            ]),
            startPoint: UnitPoint(x: 0.49, y: -0.07),
            endPoint: UnitPoint(x: 0.5, y: 0.9)
        )
        .edgesIgnoringSafeArea(.all)
    }
    
    static var foreground: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(hex: "FB6448"), location: 0),
                .init(color: Color(hex: "FC0959"), location: 1)
            ]),
            startPoint: UnitPoint(x: 0.49, y: -0.07),
            endPoint: UnitPoint(x: 0.5, y: 0.9)
        )
    }
}
