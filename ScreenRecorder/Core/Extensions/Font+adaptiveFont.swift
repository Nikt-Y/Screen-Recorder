import SwiftUI

extension Font {
    static func adaptiveFont(size: CGFloat, weight: Font.Weight = .regular, fontName: String? = nil) -> Font {
        
        let screenWidth = UIScreen.main.bounds.width
        var adjustedSize = size
        
        // Если устройство — iPad, увеличиваем размер шрифта на 20%
        if UIDevice.current.userInterfaceIdiom == .pad {
            adjustedSize = size * 1.2
        }
        // Для маленьких экранов (iPhone SE и т. д.) уменьшаем размер на 10%
        else if screenWidth <= 380 {
            adjustedSize = size * 0.9
        }
        // Для iPhone 16 Pro Max и аналогичных увеличиваем размер на 8%
        else if screenWidth >= 435 {
            adjustedSize = size * 1.08
        }
        // Для iPhone 14 и 15 Pro Max увеличиваем размер на 7%
        else if screenWidth >= 420 {
            adjustedSize = size * 1.07
        }
        // Во всех остальных случаях используем обычный размер
       
        // Если передано имя кастомного шрифта и он доступен, используем его
        if let fontName = fontName, UIFont(name: fontName, size: adjustedSize) != nil {
            return .custom(fontName, size: adjustedSize)
        } else {
            // В противном случае используем системный шрифт с заданным весом
            return .system(size: adjustedSize, weight: weight)
        }
    }
}
