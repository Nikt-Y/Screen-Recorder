import SwiftUI

struct RootView: View {
    @StateObject var router: Router = Assembly.shared.router

    var body: some View {
        NavigationStack(path: $router.path) {
            if true {
                Assembly.shared.makeMainScreen()
                    .navigationDestination(for: Router.AppScreen.self) { screen in
                        switch screen {
                        case .onboarding:
                            Assembly.shared.makeOnboardingScreen()
                        case .paywall:
                            Assembly.shared.makePaywallScreen()
                        case .videoPreview(let url):
                            Assembly.shared.makeVideoPreviewScreen(videoURL: url)
                        case .videoEditor(let url):
                            Assembly.shared.makeVideoEditorScreen(videoURL: url)
                        case .faceReaction(let url):
                            Assembly.shared.makeFaceReactionScreen(videoURL: url)
                        case .voiceComment(let url):
                            Assembly.shared.makeVoiceCommentScreen(videoURL: url)
                        }
                    }
            } else {
                Assembly.shared.makeOnboardingScreen()
                    .navigationDestination(for: Router.AppScreen.self) { screen in
                        switch screen {
                        case .onboarding:
                            Assembly.shared.makeOnboardingScreen()
                        case .paywall:
                            Assembly.shared.makePaywallScreen()
                        default:
                            EmptyView()
                        }
                    }
            }
        }
    }
}
