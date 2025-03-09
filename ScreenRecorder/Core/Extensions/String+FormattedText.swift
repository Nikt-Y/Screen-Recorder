import SwiftUI

extension String {
    func formattedText(font: Font, color: Color = Color(hex: "B6B6B6"), highlightedColor: Color = .black) -> Text {
        var result = Text("")
        var remainingText = self
        
        while let startRange = remainingText.range(of: "**") {
            // Текст до выделенного фрагмента – обычный
            let prefix = String(remainingText[..<startRange.lowerBound])
            result = result + Text(prefix)
                .font(font)
                .foregroundColor(color)
            
            // Убираем начальный маркер **
            remainingText = String(remainingText[startRange.upperBound...])
            
            // Ищем закрывающий маркер **
            guard let endRange = remainingText.range(of: "**") else {
                // Если закрывающий маркер не найден, добавляем оставшийся текст как обычный
                result = result + Text(remainingText)
                    .font(font)
                    .foregroundColor(color)
                return result
            }
            
            // Выделенный фрагмент – с выделением
            let highlighted = String(remainingText[..<endRange.lowerBound])
            result = result + Text(highlighted)
                .font(font)
                .foregroundColor(highlightedColor)
            
            // Обрезаем уже обработанную часть
            remainingText = String(remainingText[endRange.upperBound...])
        }
        
        // Добавляем оставшийся текст (если есть) как обычный
        result = result + Text(remainingText)
            .font(font)
            .foregroundColor(color)
        
        return result
    }
    
    func formattedTextGradient(font: Font, color: Color = Color(hex: "0D0606"),
                               highlightedGradient: [Color] = [Color(hex: "FB6448"), Color(hex: "FC0959")]) -> Text {
        var result = Text("")
        var remainingText = self
        
        while let startRange = remainingText.range(of: "**") {
            // Текст до выделенного фрагмента – обычный
            let prefix = String(remainingText[..<startRange.lowerBound])
            result = result + Text(prefix)
                .font(font)
                .foregroundColor(color)
            
            // Убираем начальный маркер **
            remainingText = String(remainingText[startRange.upperBound...])
            
            // Ищем закрывающий маркер **
            guard let endRange = remainingText.range(of: "**") else {
                // Если закрывающий маркер не найден, добавляем оставшийся текст как обычный
                result = result + Text(remainingText)
                    .font(font)
                    .foregroundColor(color)
                return result
            }
            
            // Выделенный фрагмент – с градиентом
            let highlighted = String(remainingText[..<endRange.lowerBound])
            result = result + Text(highlighted)
                .font(font)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: highlightedGradient),
                        startPoint: UnitPoint(x: 0.49, y: -0.07),
                        endPoint: UnitPoint(x: 0.5, y: 0.9)
                    )
                )
            
            // Обрезаем уже обработанную часть
            remainingText = String(remainingText[endRange.upperBound...])
        }
        
        // Добавляем оставшийся текст (если есть) как обычный
        result = result + Text(remainingText)
            .font(font)
            .foregroundColor(color)
        
        return result
    }
}
