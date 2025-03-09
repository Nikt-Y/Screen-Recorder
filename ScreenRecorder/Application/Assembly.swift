import SwiftUI

final class Assembly {
    static let shared = Assembly()
    
    let screenRecordingService = VideoRecordingService()
    let router = Router()
    
    private init() {}
    
    func makeOnboardingScreen() -> some View {
        let viewModel = OnboardingViewModel(router: router)
        return OnboardingView(viewModel: viewModel)
    }
    
    func makePaywallScreen() -> some View {
        let viewModel = PaywallViewModel(router: router)
        return PaywallView(viewModel: viewModel)
    }
    
    func makeMainScreen() -> some View {
        let viewModel = MainViewModel()
        return MainView(viewModel: viewModel)
    }
    
    func makeRecordingScreen() -> some View {
        let viewModel = RecordingScreenViewModel(recordingService: screenRecordingService, router: router)
        return RecordingScreenView(viewModel: viewModel)
    }
    
    func makeVideoPreviewScreen(videoURL: URL) -> some View {
        let viewModel = VideoPreviewViewModel(videoURL: videoURL, router: router)
        return VideoPreviewView(viewModel: viewModel)
    }
    
    func makeVideoEditorScreen(videoURL: URL) -> some View {
        let viewModel = VideoEditorViewModel(videoURL: videoURL, router: router)
        return VideoEditorScreen(viewModel: viewModel)
    }
    
    func makeFaceReactionScreen(videoURL: URL) -> some View {
        let viewModel = FaceReactionViewModel(videoURL: videoURL, router: router)
        return FaceReactionScreen(viewModel: viewModel)
    }
    
    func makeVoiceCommentScreen(videoURL: URL) -> some View {
        let viewModel = VoiceCommentViewModel(videoURL: videoURL, router: router)
        return VoiceCommentScreen(viewModel: viewModel)
    }
}

struct VideoEditorScreen: View {
    @ObservedObject var viewModel: VideoEditorViewModel
    var body: some View { Text("Video Editor") }
}
class VideoEditorViewModel: ObservableObject {
    init(videoURL: URL, router: Router) {}
}

struct FaceReactionScreen: View {
    @ObservedObject var viewModel: FaceReactionViewModel
    var body: some View { Text("Face Reaction") }
}
class FaceReactionViewModel: ObservableObject {
    init(videoURL: URL, router: Router) {}
}

struct VoiceCommentScreen: View {
    @ObservedObject var viewModel: VoiceCommentViewModel
    var body: some View { Text("Voice Comment") }
}
class VoiceCommentViewModel: ObservableObject {
    init(videoURL: URL, router: Router) {}
}
