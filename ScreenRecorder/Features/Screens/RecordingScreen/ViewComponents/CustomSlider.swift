import SwiftUI

struct CustomSlider: View {
    @Binding var value: Float
    let range: ClosedRange<Float>
    let step: Float
    
    var body: some View {
        Slider(value: $value, in: range, step: step)
            .accentColor(Color(hex: "#E93A5A"))
    }
}
