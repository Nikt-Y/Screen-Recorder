import SwiftUI

struct PickerItem<Tab: Hashable> {
    let title: String
    let tab: Tab
}

struct CustomPicker<Tab: Hashable>: View {
    @Binding var selectedTab: Tab
    let tabs: [PickerItem<Tab>]
    
    var cornerRadius: CGFloat = 16
    private var totalWidth: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return UIScreen.main.bounds.width / 2
        } else {
            return UIScreen.main.bounds.width - 90
        }
    }
    
    private var tabWidth: CGFloat {
        totalWidth / CGFloat(tabs.count)
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            BlurView(style: .regular)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            
            let selectedIndex = tabs.firstIndex { $0.tab == selectedTab } ?? 0
            
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(hex: "FB6448"), location: 0),
                            .init(color: Color(hex: "FC0959"), location: 1)
                        ]),
                        startPoint: UnitPoint(x: 0.49, y: -0.07),
                        endPoint: UnitPoint(x: 0.5, y: 0.9)
                    )
                )
                .frame(width: tabWidth)
                .offset(x: CGFloat(selectedIndex) * tabWidth)
                .animation(.spring(response: 0.3, dampingFraction: 0.9), value: selectedTab)
            
            HStack(spacing: 0) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    pickerButton(
                        title: tabs[index].title,
                        tab: tabs[index].tab
                    )
                }
            }
        }
        .frame(width: totalWidth, height: 40)
        .shadow(color: .gray.opacity(0.18), radius: 5, x: 0, y: 4)
    }
    
    private func pickerButton(title: String, tab: Tab) -> some View {
        Button {
            withAnimation {
                selectedTab = tab
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            Text(title)
                .foregroundColor(.white)
                .font(.adaptiveFont(size: 18, fontName: "PlusJakartaSans-Regular_Bold"))
                .padding(.vertical, 10)
                .frame(width: tabWidth)
                .contentShape(Rectangle())
        }
    }
}
