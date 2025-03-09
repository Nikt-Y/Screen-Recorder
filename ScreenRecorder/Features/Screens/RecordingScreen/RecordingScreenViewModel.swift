import Foundation
import Combine
import SwiftUI
import ReplayKit

final class RecordingScreenViewModel: ObservableObject {
    // MARK: - Services
    private let recordingService: VideoRecordingService
    private let router: Router
    
    // MARK: - Published properties
    @Published var settings = RecordingSettings()
    @Published var isRecording = false
    @Published var recordingTime: TimeInterval = 0
    @Published var showingSettings = false
    @Published var isPreparingPreview = false
    
    // MARK: - Private properties
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(recordingService: VideoRecordingService, router: Router) {
        self.recordingService = recordingService
        self.router = router
    }
    
    // MARK: - Public methods
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    func showSettings() {
        showingSettings = true
    }
    
    func hideSettings() {
        showingSettings = false
    }
    
    func updateSettings(newSettings: RecordingSettings) {
        self.settings = newSettings
    }
    
    func openFaceReactionSettings() {
        // Будет реализовано в будущем
    }
    
    func openVoiceCommentSettings() {
        // Будет реализовано в будущем
    }
    
    func openAppSettings() {
        // Открывает настройки приложения в системных настройках
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Private methods
    private func startRecording() {
        let config = settings.toRecordingConfiguration()
        
        recordingService.startRecording(config: config) { [weak self] success in
            guard let self = self else { return }
            
            if success {
                self.isRecording = true
                self.startTimer()
            }
        }
    }
    
    private func stopRecording() {
        isPreparingPreview = true
        
        recordingService.stopRecording { [weak self] success, url, previewController in
            guard let self = self else { return }
            
            self.isRecording = false
            self.stopTimer()
            self.isPreparingPreview = false
            
            if success {
                if let url = url {
                    // Показываем наш кастомный интерфейс предпросмотра
                    self.router.navigate(to: .videoPreview(url: url))
                } else if let previewController = previewController {
                    // Используем стандартный ReplayKit превью если нет URL
                    self.router.presentReplayKitPreview(previewController: previewController)
                }
            }
        }
    }
    
    private func startTimer() {
        recordingTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.recordingTime += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02dm %02ds", minutes, seconds)
    }
}
