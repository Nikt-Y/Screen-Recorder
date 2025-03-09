import SwiftUI

struct CustomButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.adaptiveFont(size: 18, fontName: "PlusJakartaSans-Regular_ExtraBold"))
                .padding(.vertical, 21.5)
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .background(
                    AppGradients.backgroundView
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 27.0)
                )
                .shadow(color: Color(hex: "FF294E").opacity(0.29), radius: 4, x: 0, y: 4)
        }
    }
}

struct CustomButton_Previews: PreviewProvider {
    static var previews: some View {
        CustomButton(title: "Continue", action: {})
    }
}
