import SwiftUI
import ReplayKit

final class Router: ObservableObject {
    enum AppScreen: Hashable {
        case onboarding
        case paywall
        case videoPreview(url: URL)
        case videoEditor(url: URL)
        case faceReaction(url: URL)
        case voiceComment(url: URL)
    }
    
    @Published var path: [AppScreen] = []
    @Published var isOnboardingCompleted: Bool {
        didSet {
            UserDefaultsService.isOnboardingComplete = isOnboardingCompleted
        }
    }
    
    // Для модальных презентаций
    @Published var presentedPreviewController: RPPreviewViewController?
    @Published var shareItems: [Any]?
    
    init() {
        isOnboardingCompleted = UserDefaultsService.isOnboardingComplete
    }
    
    func navigate(to screen: AppScreen) {
        path.append(screen)
    }
    
    func navigateBack() {
        path.removeLast()
    }
    
    func navigateToRoot() {
        path.removeLast(path.count)
    }
    
    // Необходимо сохранить эти методы, так как они не просто обертки над navigate
    func presentReplayKitPreview(previewController: RPPreviewViewController) {
        presentedPreviewController = previewController
    }
    
    func presentShareSheet(items: [Any]) {
        shareItems = items
    }
    
    func dismissShareSheet() {
        shareItems = nil
    }
}
