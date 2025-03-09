import Foundation
import ReplayKit
import Photos
import UIKit

class VideoRecordingService: NSObject, RPPreviewViewControllerDelegate {
    private let recorder = RPScreenRecorder.shared()
    private var isRecording = false
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var currentConfig: RecordingConfiguration?
    private var stopCompletionHandler: ((Bool, URL?, RPPreviewViewController?) -> Void)?
    
    // MARK: - Logging
    
    private func log(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        print("📹 [\(timestamp)] \(message)")
    }
    
    // MARK: - Public Methods
    
    func startRecording(config: RecordingConfiguration, completion: @escaping (Bool) -> Void) {
        log("⭐️ startRecording called with config: \(config.resolution), \(config.bitrate)Mbps, \(config.framerate)fps")
        
        guard !isRecording else {
            log("❌ Already recording, ignoring start command")
            completion(false)
            return
        }
        
        // Check photo library permissions first
        checkPhotoLibraryPermission { [weak self] hasPermission in
            guard let self = self else { return }
            
            guard hasPermission else {
                self.log("❌ No photo library permission")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            self.log("✅ Photo library permission granted")
            self.currentConfig = config
            
            // Register for app lifecycle notifications
            self.log("📝 Registering for app lifecycle notifications")
            self.registerForAppStateNotifications()
            
            // Begin background task
            self.log("🔙 Starting background task")
            self.startBackgroundTask()
            
            // Apply recording configuration - микрофон всегда отключен
            self.log("🎤 Setting microphone disabled")
            self.recorder.isMicrophoneEnabled = false
            
            // Start recording
            self.log("🚀 Starting recording")
            self.recorder.startRecording { [weak self] error in
                guard let self = self else { return }
                
                if let error = error {
                    self.log("❌ Start recording error: \(error.localizedDescription)")
                    self.endBackgroundTask()
                    DispatchQueue.main.async {
                        completion(false)
                    }
                    return
                }
                
                self.log("✅ Recording started successfully")
                self.isRecording = true
                DispatchQueue.main.async {
                    completion(true)
                }
            }
        }
    }
    
    func stopRecording(completion: @escaping (Bool, URL?, RPPreviewViewController?) -> Void) {
        log("⏹️ stopRecording called")
        
        guard isRecording else {
            log("❌ Not recording, ignoring stop command")
            completion(false, nil, nil)
            return
        }
        
        // Store completion handler for later use
        stopCompletionHandler = completion
        
        // Unregister notifications
        log("📝 Unregistering app state notifications")
        unregisterForAppStateNotifications()
        
        // Stop recording and show preview
        log("⏹️ Stopping recording with preview")
        recorder.stopRecording { [weak self] (previewController, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.log("❌ Stop recording error: \(error.localizedDescription)")
                self.cleanupRecording()
                DispatchQueue.main.async {
                    completion(false, nil, nil)
                }
                return
            }
            
            guard let previewController = previewController else {
                self.log("❌ No preview controller returned")
                self.cleanupRecording()
                DispatchQueue.main.async {
                    completion(false, nil, nil)
                }
                return
            }
            
            self.log("✅ Recording stopped, returning preview controller")
            
            // Set delegate to handle preview controller actions
            previewController.previewControllerDelegate = self
            
            // Get the latest video asset
            self.fetchLatestVideoAsset { assetID in
                if let assetID = assetID {
                    self.log("✅ Found latest video asset: \(assetID)")
                    
                    // Save metadata
                    self.saveVideoMetadata(assetID: assetID)
                    
                    // Get URL for the asset for preview
                    self.getURLForAsset(assetID: assetID) { url in
                        self.cleanupRecording()
                        
                        DispatchQueue.main.async {
                            completion(true, url, previewController)
                        }
                    }
                } else {
                    // Даже если не удалось найти ассет, все равно возвращаем previewController
                    self.cleanupRecording()
                    
                    DispatchQueue.main.async {
                        completion(true, nil, previewController)
                    }
                }
            }
        }
    }
    
    func isCurrentlyRecording() -> Bool {
        return isRecording
    }
    
    // MARK: - RPPreviewViewControllerDelegate
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        log("✅ Preview controller did finish")
        
        previewController.dismiss(animated: true) { [weak self] in
            self?.log("Preview controller dismissed")
        }
    }
    
    func previewControllerDidCancel(_ previewController: RPPreviewViewController) {
        log("⚠️ Preview controller did cancel")
        
        previewController.dismiss(animated: true) { [weak self] in
            self?.log("Preview controller dismissed after cancel")
        }
    }
    
    // MARK: - Private Methods
    
    private func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        log("📸 Photo library authorization status: \(status.rawValue)")
        
        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            log("📸 Requesting photo library authorization")
            PHPhotoLibrary.requestAuthorization { newStatus in
                self.log("📸 New photo library authorization status: \(newStatus.rawValue)")
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    private func fetchLatestVideoAsset(completion: @escaping (String?) -> Void) {
        log("🔍 Fetching latest video asset")
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .video, options: options)
        
        log("🔍 Found \(fetchResult.count) video assets")
        
        if let asset = fetchResult.firstObject {
            completion(asset.localIdentifier)
        } else {
            completion(nil)
        }
    }
    
    private func getURLForAsset(assetID: String, completion: @escaping (URL?) -> Void) {
        log("🔍 Getting URL for asset ID: \(assetID)")
        
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetID], options: nil)
        
        guard let asset = fetchResult.firstObject else {
            log("❌ No asset found with ID: \(assetID)")
            completion(nil)
            return
        }
        
        let options = PHVideoRequestOptions()
        options.version = .original
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
            if let urlAsset = avAsset as? AVURLAsset {
                self.log("✅ Got URL asset: \(urlAsset.url)")
                DispatchQueue.main.async {
                    completion(urlAsset.url)
                }
            } else {
                self.log("❌ Failed to get URL asset")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    private func saveVideoMetadata(assetID: String) {
        log("💾 Saving video metadata for asset ID: \(assetID)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = dateFormatter.string(from: Date())
        
        // Save configuration values in metadata if available
        var title = "Screen Recording \(formattedDate)"
        
        if let config = currentConfig {
            title += " (\(config.resolution), \(config.bitrate)Mbps, \(config.framerate)fps)"
        }
        
        let metadata: [String: Any] = [
            "assetID": assetID,
            "creationDate": Date(),
            "title": title
        ]
        
        var recordings = UserDefaults.standard.array(forKey: "screenRecordings") as? [[String: Any]] ?? []
        recordings.append(metadata)
        UserDefaults.standard.set(recordings, forKey: "screenRecordings")
        
        log("✅ Saved metadata to UserDefaults, total recordings: \(recordings.count)")
    }
    
    private func cleanupRecording() {
        log("🧹 Cleaning up recording")
        
        // End background task
        endBackgroundTask()
        
        // Reset recording state
        isRecording = false
        currentConfig = nil
        
        log("✅ Cleanup complete")
    }
    
    // MARK: - Background Task Handling
    
    private func startBackgroundTask() {
        if backgroundTask != .invalid {
            log("🔙 Ending existing background task: \(backgroundTask.rawValue)")
            UIApplication.shared.endBackgroundTask(backgroundTask)
        }
        
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.log("⏱️ Background task expiring")
            self?.endBackgroundTask()
        }
        
        log("🔙 Started background task: \(backgroundTask.rawValue)")
    }
    
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            log("🔙 Ending background task: \(backgroundTask.rawValue)")
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    // MARK: - App Lifecycle Management
    
    private func registerForAppStateNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppWillTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }
    
    private func unregisterForAppStateNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willTerminateNotification, object: nil)
    }
    
    @objc private func handleAppWillResignActive() {
        log("📱 App will resign active")
        // App is going to background, ensure background task is active
        if isRecording {
            log("🔙 Refreshing background task before entering background")
            startBackgroundTask()
        }
    }
    
    @objc private func handleAppDidBecomeActive() {
        log("📱 App did become active")
        // App returned to foreground
    }
    
    @objc private func handleAppWillTerminate() {
        log("📱 App will terminate")
        // App is being terminated, try to save recording if possible
        if isRecording {
            log("⚠️ Attempting emergency stop of recording before termination")
            // This is a last-ditch effort, may not complete in time
            stopRecording { _, _, _ in }
        }
    }
}
