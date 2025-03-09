import SwiftUI

struct SheetHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        // Если в иерархии будет несколько значений,
        // берём максимум (или можно взять nextValue(), если нужна последняя высота).
        value = max(value, nextValue())
    }
}

struct IntrinsicHeightContainer<Content: View>: View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            content()
            // Говорим системе: «расти по вертикали ровно настолько, насколько надо»
                .fixedSize(horizontal: false, vertical: true)
        }
        .background(
            GeometryReader { geo in
                // Кладём «прозрачный» слой и через него узнаём высоту
                Color.clear
                    .preference(key: SheetHeightPreferenceKey.self, value: geo.size.height)
            }
        )
    }
}
