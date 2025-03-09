import SwiftUI

enum Tab {
    case recording
    case history
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    private let capsuleWidth: CGFloat
    
    init(selectedTab: Binding<Tab>) {
        self._selectedTab = selectedTab
        self.capsuleWidth = (UIScreen.main.bounds.width - 48 - 32) / 2
    }
    
    var body: some View {
        HStack(spacing: 0) {
            tabButton(
                title: NSLocalizedString("Recording", comment: ""),
                iconSelected: "recordingTabSelected",
                iconDefault: "recordingTabDefault",
                tab: .recording
            )
            .padding(.leading, 16)
            
            tabButton(
                title: NSLocalizedString("History", comment: ""),
                iconSelected: "historyTabSelected",
                iconDefault: "historyTabDefault",
                tab: .history
            )
            .padding(.trailing, 16)
        }
        .padding(.vertical, 14.5)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
                .overlay(
                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                Color(hex: "FFF3F3")
                            )
                            .frame(
                                width: capsuleWidth,
                                height: geometry.size.height - 29
                            )
                            .offset(x: selectedTab == .recording ? 15 : 15 + capsuleWidth, y: 14.5)
                    }
                )
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 34)
    }
    
    private func tabButton(title: String, iconSelected: String, iconDefault: String, tab: Tab) -> some View {
        let isSelected = selectedTab == tab
        
        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                selectedTab = tab
            }
        } label: {
            HStack {
                Image(isSelected ? iconSelected : iconDefault)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
                    .padding(.vertical, 15)

                if isSelected {
                    Text(title)
                        .foregroundStyle(AppGradients.foreground)
                } else {
                    Text(title)
                        .foregroundColor(Color(hex: "BD9192"))
                }
                
            }
            .font(.adaptiveFont(size: 18, fontName: "PlusJakartaSans-Regular_Bold"))
            .frame(maxWidth: .infinity)
        }
    }
}

struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            CustomTabBar(selectedTab: .constant(.history))
        }
        .background(Color(hex: "F6F6F6"))
        .edgesIgnoringSafeArea(.all)
    }
}
