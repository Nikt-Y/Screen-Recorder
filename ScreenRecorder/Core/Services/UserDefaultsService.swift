import Foundation

struct UserDefaultsService {
    private static let defaults = UserDefaults.standard
    
    // MARK: - Keys
    private enum Keys {
        static let isOnboardingComplete = "isOnboardingComplete"
        static let screenRecordings = "screenRecordings"
    }
    
    // MARK: - Onboarding
    static var isOnboardingComplete: Bool {
        get {
            defaults.bool(forKey: Keys.isOnboardingComplete)
        }
        set {
            defaults.set(newValue, forKey: Keys.isOnboardingComplete)
        }
    }
    
    // MARK: - Screen Recordings
    static var screenRecordings: [[String: Any]] {
        get {
            defaults.array(forKey: Keys.screenRecordings) as? [[String: Any]] ?? []
        }
        set {
            defaults.set(newValue, forKey: Keys.screenRecordings)
        }
    }
    
    static func addScreenRecording(metadata: [String: Any]) {
        var recordings = screenRecordings
        recordings.append(metadata)
        screenRecordings = recordings
    }
}
