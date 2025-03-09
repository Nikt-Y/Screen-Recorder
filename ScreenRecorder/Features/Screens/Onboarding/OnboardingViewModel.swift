import SwiftUI
import StoreKit

class OnboardingViewModel: ObservableObject {
    private let router: Router
    
    init(router: Router) {
        self.router = router
    }
    
    func endOnboarding() {
//        router.navigate(to: .faceID)
    }
    
    func showRequestReview() {
        SKStoreReviewController.requestReview()
    }
    
    func onRestorePressed() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
//        Task {
//            let success = await purchaseService.restorePurchases()
//            if success {
//                completeOnboarding()
//            }
//        }
    }
    
    func onTermsPressed() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let url = Config.termsOfUseURL
        if let url = url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func onPrivacyPressed() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let url = Config.privacyPolicyURL
        if let url = url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    private func completeOnboarding() {
//        router.isOnboardingCompleted = true
        router.navigateToRoot()
    }
}
