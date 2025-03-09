import SwiftUI

enum PaywallTab: Hashable {
    case year
    case month
    case week
    case day
}

class PaywallViewModel: ObservableObject {
    @Published var selectedTab: PaywallTab = .year
    @Published var showNoInternetError: Bool = false
    
    private let router: Router
    private let purchaseService: MockPurchaseService
    
    // MARK: - Initialization
    
    init(router: Router, purchaseService: MockPurchaseService = MockPurchaseService(paywallType: 2)) {
        self.router = router
        self.purchaseService = purchaseService
    }
    
    // MARK: - UI Properties
    
    var titleText = "Screen Recorder **PRO**"
    
    var subtitleText: String {
        if showNoInternetError {
            return "It looks like you have no internet connection. We can't load the available subscriptions. Please check your connection and try again."
        }
        
        let productIndex = selectedProductIndex
        if productIndex < purchaseService.products.count {
            let price = purchaseService.priceText(for: productIndex)
            let period = purchaseService.subscriptionPeriodDescription(for: productIndex)?.lowercased() ?? "week"
            return "Screen recorder with audio from the mic and face reaction at \(price)/\(period)"
        }
        
        return "Screen recorder with audio from the mic and face reaction"
    }
    
    var imageName: String {
        return "paywall\(purchaseService.paywallType)"
    }
    
    var showTabBar: Bool {
        return purchaseService.paywallType == 2 && purchaseService.products.count > 1
    }
    
    var continueButtonTitle: String {
        return NSLocalizedString("Continue", comment: "")
    }
    
    // MARK: - Product Selection Logic
    
    var selectedProductIndex: Int {
        // For Type 1: always return the product with shortest period
        if purchaseService.paywallType == 1 || purchaseService.products.count <= 1 {
            // Find the product with shortest period (daily/weekly would be prioritized)
            let productsByPeriod = sortedProductsByPeriod()
            return productsByPeriod.last?.index ?? 0
        }
        
        // For Type 2: return index based on selected tab
        let productsByPeriod = sortedProductsByPeriod()
        
        switch selectedTab {
        case .year:
            return productsByPeriod.first(where: { $0.period == .year })?.index ?? 0
        case .month:
            return productsByPeriod.first(where: { $0.period == .month })?.index ?? 0
        case .week:
            return productsByPeriod.first(where: { $0.period == .week })?.index ?? 0
        case .day:
            return productsByPeriod.first(where: { $0.period == .day })?.index ?? 0
        }
    }
    
    // Get available tabs for the tab bar
    var availableTabs: [PickerItem<PaywallTab>] {
        let productsByPeriod = sortedProductsByPeriod()
        var tabs: [PickerItem<PaywallTab>] = []
        
        // Create tabs in order: year, month, week, day
        if productsByPeriod.contains(where: { $0.period == .year }) {
            tabs.append(PickerItem(title: "Year", tab: .year))
        }
        
        if productsByPeriod.contains(where: { $0.period == .month }) {
            tabs.append(PickerItem(title: "Month", tab: .month))
        }
        
        if productsByPeriod.contains(where: { $0.period == .week }) {
            tabs.append(PickerItem(title: "Week", tab: .week))
        }
        
        if productsByPeriod.contains(where: { $0.period == .day }) {
            tabs.append(PickerItem(title: "Day", tab: .day))
        }
        
        return tabs
    }
    
    // MARK: - Methods
    
    @MainActor
    func loadProducts() {
        purchaseService.loadProducts()
        
        // Check if products are available after a short delay to allow them to load
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            if self.purchaseService.products.isEmpty {
                self.showNoInternetError = true
            } else {
                self.showNoInternetError = false
                // Set the initial tab based on available products
                self.setupInitialTab()
            }
        }
    }
    
    private func setupInitialTab() {
        let productsByPeriod = sortedProductsByPeriod()
        
        if let yearlyProduct = productsByPeriod.first(where: { $0.period == .year }) {
            selectedTab = .year
        } else if let monthlyProduct = productsByPeriod.first(where: { $0.period == .month }) {
            selectedTab = .month
        } else if let weeklyProduct = productsByPeriod.first(where: { $0.period == .week }) {
            selectedTab = .week
        } else if let dailyProduct = productsByPeriod.first(where: { $0.period == .day }) {
            selectedTab = .day
        }
    }
    
    // Helper to sort products by period for consistent display
    private func sortedProductsByPeriod() -> [(index: Int, period: PaywallTab)] {
        var result: [(index: Int, period: PaywallTab)] = []
        
        for (index, product) in purchaseService.products.enumerated() {
            guard let skProduct = product.skProduct, let period = skProduct.subscriptionPeriod else {
                continue
            }
            
            switch period.unit {
            case .day:
                if period.numberOfUnits >= 7 {
                    result.append((index, .week))
                } else {
                    result.append((index, .day))
                }
            case .week:
                result.append((index, .week))
            case .month:
                result.append((index, .month))
            case .year:
                result.append((index, .year))
            @unknown default:
                continue
            }
        }
        
        // Sort by period length (longest first: year > month > week > day)
        return result.sorted { (product1, product2) -> Bool in
            let periodOrder: [PaywallTab] = [.year, .month, .week, .day]
            guard let index1 = periodOrder.firstIndex(of: product1.period),
                  let index2 = periodOrder.firstIndex(of: product2.period) else {
                return false
            }
            return index1 < index2
        }
    }
    
    // MARK: - User Actions
    
    func onTabSelected(tab: PaywallTab) {
        selectedTab = tab
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    func onContinuePressed() {
        Task {
            let success = await purchaseService.purchase(
                productIndex: selectedProductIndex,
                trialEnabled: false // Trial is not supported in the new app
            )
            await MainActor.run {
                if success {
                    completeOnboarding()
                } else {
                    print("Purchase failed")
                }
            }
        }
    }
    
    func onRestorePressed() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Task {
            let success = await purchaseService.restorePurchases()
            await MainActor.run {
                if success {
                    completeOnboarding()
                }
            }
        }
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
    
    func onSkipPressed() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        completeOnboarding()
    }
    
    // MARK: - Private Helpers
    
    private func completeOnboarding() {
        if router.isOnboardingCompleted {
            router.navigateBack()
        } else {
            router.isOnboardingCompleted = true
            router.navigateToRoot()
        }
    }
}
