import Foundation
import StoreKit
import SwiftUI

// Simple mock product to replace ApphudProduct
class MockProduct {
    var id: String
    var skProduct: MockSKProduct?
    
    init(id: String, skProduct: MockSKProduct?) {
        self.id = id
        self.skProduct = skProduct
    }
}

// Simple mock SKProduct to simulate StoreKit product
class MockSKProduct {
    var productIdentifier: String
    var price: NSDecimalNumber
    var priceLocale: Locale
    var subscriptionPeriod: MockSubscriptionPeriod?
    var introductoryPrice: MockIntroductoryPrice?
    
    init(productIdentifier: String,
         price: NSDecimalNumber,
         priceLocale: Locale = Locale(identifier: "en_US"),
         subscriptionPeriod: MockSubscriptionPeriod? = nil,
         introductoryPrice: MockIntroductoryPrice? = nil) {
        self.productIdentifier = productIdentifier
        self.price = price
        self.priceLocale = priceLocale
        self.subscriptionPeriod = subscriptionPeriod
        self.introductoryPrice = introductoryPrice
    }
}

// Mock SubscriptionPeriod to replace SKProductSubscriptionPeriod
class MockSubscriptionPeriod {
    enum Unit: Int {
        case day = 0
        case week = 1
        case month = 2
        case year = 3
    }
    
    var unit: Unit
    var numberOfUnits: Int
    
    init(unit: Unit, numberOfUnits: Int) {
        self.unit = unit
        self.numberOfUnits = numberOfUnits
    }
}

// Mock IntroductoryPrice to replace SKProductDiscount
class MockIntroductoryPrice {
    var price: NSDecimalNumber
    var subscriptionPeriod: MockSubscriptionPeriod
    
    init(price: NSDecimalNumber, subscriptionPeriod: MockSubscriptionPeriod) {
        self.price = price
        self.subscriptionPeriod = subscriptionPeriod
    }
}

// Mock PurchaseService that can replace the real PurchaseService
class MockPurchaseService: ObservableObject {
    @Published var paywallType: Int = 2  // Hardcoded to type 2 for showing the tab bar
    
    // Hardcoded products for UI testing
    private(set) var paywallProducts: [MockProduct] = []
    private(set) var trialProduct: MockProduct?
    
    var products: [MockProduct] {
        return paywallProducts
    }
    
    init(paywallType: Int = 2) {
        self.paywallType = paywallType
        setupMockProducts()
    }
    
    private func setupMockProducts() {
        // Create yearly subscription product
        let yearlyProduct = MockProduct(
            id: "com.app.yearly",
            skProduct: MockSKProduct(
                productIdentifier: "com.app.yearly",
                price: NSDecimalNumber(string: "23.99"),
                subscriptionPeriod: MockSubscriptionPeriod(unit: .year, numberOfUnits: 1)
            )
        )
        
        // Create weekly subscription product
        let weeklyProduct = MockProduct(
            id: "com.app.weekly",
            skProduct: MockSKProduct(
                productIdentifier: "com.app.weekly",
                price: NSDecimalNumber(string: "3.99"),
                subscriptionPeriod: MockSubscriptionPeriod(unit: .week, numberOfUnits: 1)
            )
        )
        
        // Add products to the list
        paywallProducts = [yearlyProduct, weeklyProduct]
        
        // Setup trial product (just in case)
        let trialPeriod = MockSubscriptionPeriod(unit: .day, numberOfUnits: 3)
        trialProduct = MockProduct(
            id: "com.app.trial",
            skProduct: MockSKProduct(
                productIdentifier: "com.app.trial",
                price: NSDecimalNumber(string: "1.99"),
                subscriptionPeriod: MockSubscriptionPeriod(unit: .week, numberOfUnits: 1),
                introductoryPrice: MockIntroductoryPrice(
                    price: NSDecimalNumber(string: "0.00"),
                    subscriptionPeriod: trialPeriod
                )
            )
        )
    }
    
    // MARK: - Required methods to match PurchaseService interface
    
    @MainActor
    func loadProducts() {
        // Do nothing - products are already loaded
        print("[MockPurchaseService] loadProducts called - products already loaded")
    }
    
    @MainActor
    func purchase(productIndex: Int, trialEnabled: Bool) async -> Bool {
        // Always return success for UI testing
        print("[MockPurchaseService] Purchase called for product index: \(productIndex), trial: \(trialEnabled), type \(products[productIndex].skProduct?.productIdentifier)")
        return true
    }
    
    func priceText(for productIndex: Int) -> String {
        guard productIndex < products.count,
              let skProduct = products[productIndex].skProduct
        else {
            return NSLocalizedString("N/A", comment: "")
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = skProduct.priceLocale
        return formatter.string(from: skProduct.price) ?? NSLocalizedString("N/A", comment: "")
    }
    
    func oldPriceText(for productIndex: Int) -> String {
        guard productIndex < products.count,
              let skProduct = products[productIndex].skProduct
        else {
            return NSLocalizedString("N/A", comment: "")
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = skProduct.priceLocale
        
        let oldPrice = skProduct.price.multiplying(by: NSDecimalNumber(value: 1.5))
        return formatter.string(from: oldPrice) ?? NSLocalizedString("N/A", comment: "")
    }
    
    func productPriceAndLocale(for productIndex: Int) -> (NSDecimalNumber, Locale)? {
        guard productIndex < products.count,
              let skProduct = products[productIndex].skProduct
        else {
            return nil
        }
        return (skProduct.price, skProduct.priceLocale)
    }
    
    func subscriptionPeriodDescription(for productIndex: Int) -> String? {
        guard productIndex < paywallProducts.count,
              let skProduct = paywallProducts[productIndex].skProduct,
              let period = skProduct.subscriptionPeriod else {
            return nil
        }
        
        switch period.unit {
        case .day:
            if period.numberOfUnits >= 7 {
                return NSLocalizedString("Weekly", comment: "Subscription plan unit: per week")
            }
            return NSLocalizedString("Daily", comment: "Subscription plan unit: per day")
        case .week:
            return NSLocalizedString("Weekly", comment: "Subscription plan unit: per week")
        case .month:
            return NSLocalizedString("Monthly", comment: "Subscription plan unit: per month")
        case .year:
            return NSLocalizedString("Yearly", comment: "Subscription plan unit: per year")
        }
    }
    
    func subPriceText(for index: Int) -> String {
        guard let (price, locale) = productPriceAndLocale(for: index),
              let skProduct = paywallProducts[index].skProduct,
              let period = skProduct.subscriptionPeriod
        else {
            return NSLocalizedString("N/A", comment: "")
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        
        switch period.unit {
        case .week:
            let dailyPrice = price.dividing(by: NSDecimalNumber(value: 7))
            return String(format: NSLocalizedString("%@ a day", comment: ""), formatter.string(from: dailyPrice) ?? NSLocalizedString("N/A", comment: ""))
        case .month:
            let monthlyDays = 30.0
            let dailyPrice = price.dividing(by: NSDecimalNumber(value: monthlyDays))
            return String(format: NSLocalizedString("%@ a day", comment: ""), formatter.string(from: dailyPrice) ?? NSLocalizedString("N/A", comment: ""))
        case .year:
            let weeklyPrice = price.dividing(by: NSDecimalNumber(value: 365))
            return String(format: NSLocalizedString("%@ a day", comment: ""), formatter.string(from: weeklyPrice) ?? NSLocalizedString("N/A", comment: ""))
        case .day:
            if period.numberOfUnits >= 7 {
                let dailyPrice = price.dividing(by: NSDecimalNumber(value: 7))
                return String(format: NSLocalizedString("%@ a day", comment: ""), formatter.string(from: dailyPrice) ?? NSLocalizedString("N/A", comment: ""))
            }
            return String(format: NSLocalizedString("%@ / day", comment: ""), formatter.string(from: price) ?? NSLocalizedString("N/A", comment: ""))
        }
    }
    
    @MainActor
    func restorePurchases() async -> Bool {
        // Always return success for UI testing
        print("[MockPurchaseService] Restore purchases called")
        return true
    }
    
    func hasActiveSubscription() -> Bool {
        return false
    }
    
    // MARK: - Trial-related methods
    
    @MainActor
    func purchaseTrialProduct() async -> Bool {
        print("[MockPurchaseService] Trial purchase called")
        return true
    }
    
    func priceTextForTrial() -> String {
        guard let trialProduct = trialProduct,
              let skProduct = trialProduct.skProduct else {
            return NSLocalizedString("N/A", comment: "")
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = skProduct.priceLocale
        return formatter.string(from: skProduct.price) ?? NSLocalizedString("N/A", comment: "")
    }
    
    func oldPriceTextForTrial() -> String {
        guard let trialProduct = trialProduct,
              let skProduct = trialProduct.skProduct else {
            return NSLocalizedString("N/A", comment: "")
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = skProduct.priceLocale
        
        let multipliedPrice = skProduct.price.multiplying(by: NSDecimalNumber(value: 1.5))
        return formatter.string(from: multipliedPrice) ?? NSLocalizedString("N/A", comment: "")
    }
    
    func trialProductPriceAndLocale() -> (NSDecimalNumber, Locale)? {
        guard let trialProduct = trialProduct,
              let skProduct = trialProduct.skProduct else {
            return nil
        }
        return (skProduct.price, skProduct.priceLocale)
    }
    
    func trialSubscriptionPeriodDescription() -> String {
        guard let trialProduct = trialProduct,
              let skProduct = trialProduct.skProduct,
              let period = skProduct.subscriptionPeriod else {
            return "unknown"
        }
        
        switch period.unit {
        case .day:
            if period.numberOfUnits >= 7 {
                return "week"
            }
            return "day"
        case .week:
            return "week"
        case .month:
            return "month"
        case .year:
            return "year"
        }
    }
    
    func trialDaysCount() -> Int? {
        guard let trialProduct = trialProduct,
              let skProduct = trialProduct.skProduct,
              let introPrice = skProduct.introductoryPrice else {
            return nil
        }
        
        let period = introPrice.subscriptionPeriod
        switch period.unit {
        case .day:
            return period.numberOfUnits
        case .week:
            return period.numberOfUnits * 7
        case .month:
            return period.numberOfUnits * 30
        case .year:
            return period.numberOfUnits * 365
        }
    }
}
