import Foundation

struct RecordingSettings {
    // Отображаемые значения
    var resolution: String {
        resolutionOptions[Int(resolutionSliderValue) - 1]
    }
    
    var bitrate: String {
        "\(bitrateOptions[Int(bitrateSliderValue) - 1])Mbps"
    }
    
    var framerate: String {
        "≈\(framerateOptions[Int(framerateSliderValue) - 1])fps"
    }
    
    // Значения слайдеров
    var resolutionSliderValue: Float = 3 // По умолчанию 1080p (индекс 3)
    var bitrateSliderValue: Float = 3    // По умолчанию 4Mbps (индекс 3)
    var framerateSliderValue: Float = 5  // По умолчанию 60fps (индекс 5)
    
    // Опции для каждого параметра
    let resolutionOptions = ["480p", "720p", "1080p(HD)", "1440p"]
    let bitrateOptions = [1, 2, 3, 4, 5, 6, 8, 12]
    let framerateOptions = [20, 25, 30, 50, 60]
    
    // Метод для экспорта настроек в формат, удобный для сервиса записи
    func toRecordingConfiguration() -> RecordingConfiguration {
        let selectedResolution = resolutionOptions[Int(resolutionSliderValue) - 1]
        let selectedBitrate = bitrateOptions[Int(bitrateSliderValue) - 1]
        let selectedFramerate = framerateOptions[Int(framerateSliderValue) - 1]
        
        return RecordingConfiguration(
            resolution: selectedResolution,
            bitrate: selectedBitrate,
            framerate: selectedFramerate
        )
    }
}

// Структура для передачи настроек в сервис записи
struct RecordingConfiguration {
    let resolution: String
    let bitrate: Int
    let framerate: Int
}
