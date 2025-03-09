import SwiftUI

struct FeatureOptionView: View {
    let image: String
    let title: String
    let description: String
    var badgeText: String?
    var action: () -> Void
    
    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        
        Button(action: action) {
            VStack(alignment: .center, spacing: 8) {
                
                HStack {
                    Spacer()
                    
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth * 0.3)
                }
                
                Text(title)
                    .font(.adaptiveFont(size: 20, fontName: "PlusJakartaSans-Regular_ExtraBold"))
                
                Text(description)
                    .font(.adaptiveFont(size: 16, fontName: "PlusJakartaSans-Regular_SemiBold"))
                    .foregroundColor(Color(hex: "9C9C9C"))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 29)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
        .shadow(color: .gray.opacity(0.18), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    FeatureOptionView(
        image: "faceReaction",
        title: "Face Reaction",
        description: "Record reactions to your recording",
        action: {
        }
    )
}
