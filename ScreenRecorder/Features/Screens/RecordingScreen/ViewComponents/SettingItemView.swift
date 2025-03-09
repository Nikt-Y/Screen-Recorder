import SwiftUI

struct SettingItemView: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.adaptiveFont(size: 16, fontName: "PlusJakartaSans-Regular_SemiBold"))
                    .foregroundColor(Color(hex: "9C9C9C"))
                    .lineLimit(1)

                HStack(spacing: 2) {
                    Text(value)
                        .font(.adaptiveFont(size: 18, fontName: "PlusJakartaSans-Regular_ExtraBold"))
                        .lineLimit(1)
                        
                    Image("chevronDown")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14)
                }
            }
            Spacer(minLength: 0)
        }
    }
}
