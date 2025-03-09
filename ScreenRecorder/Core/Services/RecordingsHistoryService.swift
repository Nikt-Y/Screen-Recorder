//import Foundation
//import Photos
//import UIKit
//
//// MARK: - Model
//
//struct ScreenRecording {
//    let id: String
//    let assetID: String
//    let creationDate: Date
//    var title: String
//    var asset: PHAsset?
//    var thumbnailImage: UIImage?
//    var duration: TimeInterval?
//}
//
//// MARK: - Service
//
//class RecordingsHistoryService {
//    private let photoLibrary = PHPhotoLibrary.shared()
//    
//    func getAllRecordings(completion: @escaping ([ScreenRecording]) -> Void) {
//        checkPhotoLibraryPermission { [weak self] hasPermission in
//            guard let self = self, hasPermission else {
//                completion([])
//                return
//            }
//            
//            self.fetchRecordings(completion: completion)
//        }
//    }
//    
//    private func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
//        let status = PHPhotoLibrary.authorizationStatus()
//        
//        switch status {
//        case .authorized, .limited:
//            completion(true)
//        case .notDetermined:
//            PHPhotoLibrary.requestAuthorization { newStatus in
//                DispatchQueue.main.async {
//                    completion(newStatus == .authorized || newStatus == .limited)
//                }
//            }
//        case .denied, .restricted:
//            completion(false)
//        @unknown default:
//            completion(false)
//        }
//    }
//    
//    private func fetchRecordings(completion: @escaping ([ScreenRecording]) -> Void) {
//        guard let recordingsData = UserDefaults.standard.array(forKey: "screenRecordings") as? [[String: Any]] else {
//            completion([])
//            return
//        }
//        
//        var recordings: [ScreenRecording] = []
//        
//        for recordingData in recordingsData {
//            guard let assetID = recordingData["assetID"] as? String,
//                  let creationDate = recordingData["creationDate"] as? Date,
//                  let title = recordingData["title"] as? String else {
//                continue
//            }
//            
//            let recording = ScreenRecording(
//                id: UUID().uuidString,
//                assetID: assetID,
//                creationDate: creationDate,
//                title: title
//            )
//            
//            recordings.append(recording)
//        }
//        
//        verifyAssetsExistence(recordings: recordings) { verifiedRecordings in
//            let sortedRecordings = verifiedRecordings.sorted { $0.creationDate > $1.creationDate }
//            
//            self.loadThumbnailsAndMetadata(for: sortedRecordings) { recordingsWithThumbnails in
//                completion(recordingsWithThumbnails)
//            }
//        }
//    }
//    
//    private func verifyAssetsExistence(recordings: [ScreenRecording], completion: @escaping ([ScreenRecording]) -> Void) {
//        let assetIDs = recordings.map { $0.assetID }
//        
//        let options = PHFetchOptions()
//        
//        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: assetIDs, options: options)
//        
//        var verifiedRecordings: [ScreenRecording] = []
//        var assetIDMap: [String: PHAsset] = [:]
//        
//        fetchResult.enumerateObjects { asset, _, _ in
//            assetIDMap[asset.localIdentifier] = asset
//        }
//        
//        for var recording in recordings {
//            if let asset = assetIDMap[recording.assetID] {
//                recording.asset = asset
//                verifiedRecordings.append(recording)
//            }
//        }
//        
//        if verifiedRecordings.count != recordings.count {
//            // Some recordings were removed from photo library, update stored data
//            updateStoredRecordings(verifiedRecordings)
//        }
//        
//        completion(verifiedRecordings)
//    }
//    
//    private func loadThumbnailsAndMetadata(for recordings: [ScreenRecording], completion: @escaping ([ScreenRecording]) -> Void) {
//        let imageManager = PHImageManager.default()
//        let options = PHImageRequestOptions()
//        options.deliveryMode = .opportunistic
//        options.resizeMode = .fast
//        options.isNetworkAccessAllowed = true
//        options.isSynchronous = false
//        
//        let size = CGSize(width: 160, height: 120)
//        
//        var recordingsWithData: [ScreenRecording] = recordings
//        let group = DispatchGroup()
//        
//        for i in 0..<recordingsWithData.count {
//            if let asset = recordingsWithData[i].asset {
//                group.enter()
//                
//                // Get thumbnail
//                imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { image, _ in
//                    if let image = image {
//                        recordingsWithData[i].thumbnailImage = image
//                    }
//                    
//                    // Get duration
//                    recordingsWithData[i].duration = asset.duration
//                    
//                    group.leave()
//                }
//            }
//        }
//        
//        group.notify(queue: .main) {
//            completion(recordingsWithData)
//        }
//    }
//    
//    private func updateStoredRecordings(_ recordings: [ScreenRecording]) {
//        let recordingsData = recordings.map { recording -> [String: Any] in
//            return [
//                "assetID": recording.assetID,
//                "creationDate": recording.creationDate,
//                "title": recording.title
//            ]
//        }
//        
//        UserDefaults.standard.set(recordingsData, forKey: "screenRecordings")
//    }
//    
//    func loadVideo(assetID: String, completion: @escaping (URL?, Error?) -> Void) {
//        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetID], options: nil)
//        
//        guard let asset = fetchResult.firstObject else {
//            completion(nil, NSError(domain: "com.screenrecorder", code: 5, userInfo: [NSLocalizedDescriptionKey: "Asset not found"]))
//            return
//        }
//        
//        let options = PHVideoRequestOptions()
//        options.version = .original
//        options.deliveryMode = .highQualityFormat
//        options.isNetworkAccessAllowed = true
//        
//        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, info in
//            guard let urlAsset = avAsset as? AVURLAsset else {
//                DispatchQueue.main.async {
//                    completion(nil, NSError(domain: "com.screenrecorder", code: 6, userInfo: [NSLocalizedDescriptionKey: "Failed to get URL for video"]))
//                }
//                return
//            }
//            
//            DispatchQueue.main.async {
//                completion(urlAsset.url, nil)
//            }
//        }
//    }
//    
//    func updateRecordingTitle(assetID: String, newTitle: String, completion: @escaping (Bool) -> Void) {
//        guard var recordingsData = UserDefaults.standard.array(forKey: "screenRecordings") as? [[String: Any]] else {
//            completion(false)
//            return
//        }
//        
//        var updated = false
//        for i in 0..<recordingsData.count {
//            if let storedAssetID = recordingsData[i]["assetID"] as? String, storedAssetID == assetID {
//                recordingsData[i]["title"] = newTitle
//                updated = true
//                break
//            }
//        }
//        
//        if updated {
//            UserDefaults.standard.set(recordingsData, forKey: "screenRecordings")
//            completion(true)
//        } else {
//            completion(false)
//        }
//    }
//    
//    func deleteRecordingMetadata(assetID: String, completion: @escaping (Bool) -> Void) {
//        guard var recordingsData = UserDefaults.standard.array(forKey: "screenRecordings") as? [[String: Any]] else {
//            completion(false)
//            return
//        }
//        
//        let initialCount = recordingsData.count
//        recordingsData.removeAll {
//            guard let storedAssetID = $0["assetID"] as? String else { return false }
//            return storedAssetID == assetID
//        }
//        
//        if recordingsData.count < initialCount {
//            UserDefaults.standard.set(recordingsData, forKey: "screenRecordings")
//            completion(true)
//        } else {
//            completion(false)
//        }
//    }
//    
//    func deleteRecordingCompletely(assetID: String, completion: @escaping (Bool, Error?) -> Void) {
//        // First check if the asset exists
//        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetID], options: nil)
//        
//        guard let asset = fetchResult.firstObject else {
//            // If asset doesn't exist in Photos, just delete metadata
//            deleteRecordingMetadata(assetID: assetID) { success in
//                completion(success, nil)
//            }
//            return
//        }
//        
//        // Delete from Photos Library
//        PHPhotoLibrary.shared().performChanges({
//            PHAssetChangeRequest.deleteAssets([asset] as NSArray)
//        }) { success, error in
//            if success {
//                // Also delete metadata
//                self.deleteRecordingMetadata(assetID: assetID) { metadataDeleted in
//                    completion(metadataDeleted, nil)
//                }
//            } else {
//                completion(false, error)
//            }
//        }
//    }
//    
//    // Register for Photo Library changes to keep recordings in sync
//    func registerForPhotoLibraryChanges() {
//        PHPhotoLibrary.shared().register(self)
//    }
//    
//    func unregisterForPhotoLibraryChanges() {
//        PHPhotoLibrary.shared().unregisterChangeObserver(self)
//    }
//}
//
//// MARK: - PHPhotoLibraryChangeObserver
//
//extension RecordingsHistoryService: PHPhotoLibraryChangeObserver {
//    func photoLibraryDidChange(_ changeInstance: PHChange) {
//        // When Photo Library changes (deletions, etc.), refresh our data
//        DispatchQueue.main.async { [weak self] in
//            self?.getAllRecordings { _ in
//                // Recordings updated
//                NotificationCenter.default.post(name: Notification.Name("RecordingsUpdated"), object: nil)
//            }
//        }
//    }
//}
