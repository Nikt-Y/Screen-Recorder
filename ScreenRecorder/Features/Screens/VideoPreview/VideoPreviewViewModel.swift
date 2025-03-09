import Foundation
import AVKit
import Photos
import SwiftUI

final class VideoPreviewViewModel: ObservableObject {
    // MARK: - Properties
    private let videoURL: URL
    private let router: Router
    
    @Published var player: AVPlayer?
    @Published var videoFilename: String
    @Published var videoDurationAndSize: String
    
    // MARK: - Initialization
    init(videoURL: URL, router: Router) {
        self.videoURL = videoURL
        self.router = router
        
        // Извлекаем имя файла
        let filename = videoURL.lastPathComponent
        self.videoFilename = filename
        
        // Получаем размер файла
        let fileManager = FileManager.default
        let fileSize = (try? fileManager.attributesOfItem(atPath: videoURL.path)[.size] as? Int) ?? 0
        let fileSizeString = ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
        
        // Временная строка с размером файла - позже будет обновлена с длительностью
        self.videoDurationAndSize = "\(fileSizeString)"
        
        // Асинхронно загружаем длительность
        loadVideoDuration()
    }
    
    // MARK: - Public methods
    
    func preparePlayer() {
        let playerItem = AVPlayerItem(url: videoURL)
        player = AVPlayer(playerItem: playerItem)
        player?.play()
    }
    
    func stopPlayer() {
        player?.pause()
        player = nil
    }
    
    func openVideoEditor() {
        router.navigate(to: .videoEditor(url: videoURL))
    }
    
    func shareRecording() {
        router.presentShareSheet(items: [videoURL])
    }
    
    func addFaceReaction() {
        router.navigate(to: .faceReaction(url: videoURL))
    }
    
    func addVoiceComment() {
        router.navigate(to: .voiceComment(url: videoURL))
    }
    
    // MARK: - Private methods
    
    private func loadVideoDuration() {
        let asset = AVAsset(url: videoURL)
        
        asset.loadValuesAsynchronously(forKeys: ["duration"]) { [weak self] in
            guard let self = self else { return }
            
            var error: NSError? = nil
            let status = asset.statusOfValue(forKey: "duration", error: &error)
            
            if status == .loaded {
                let duration = asset.duration.seconds
                let durationString = self.formatDuration(duration)
                
                // Извлекаем также размер файла
                let fileManager = FileManager.default
                let fileSize = (try? fileManager.attributesOfItem(atPath: self.videoURL.path)[.size] as? Int) ?? 0
                let fileSizeString = ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
                
                DispatchQueue.main.async {
                    self.videoDurationAndSize = "\(durationString) • \(fileSizeString)"
                }
            }
        }
    }
    
    private func formatDuration(_ seconds: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        return formatter.string(from: seconds) ?? "00:00"
    }
}
