import Foundation
import StoreKit
import ApphudSDK

class PurchaseService: ObservableObject {
    static let shared = PurchaseService()
    
    // Add property for paywall type
    @Published var paywallType: Int = 1  // Default to type 1
    
    private(set) var paywallProducts: [ApphudProduct] = []
    private(set) var trialProduct: ApphudProduct?
    
    var products: [ApphudProduct] {
        return paywallProducts
    }
    
    @MainActor
    func loadProducts() {
        print("[PurchaseServiceLog] loadProducts() called")
        Apphud.fetchPlacements(maxAttempts: 10) { [weak self] placements, error in
            print("[PurchaseServiceLog] fetchPlacements callback, error = \(String(describing: error?.localizedDescription))")
            guard let self = self else {
                print("[PurchaseServiceLog] self is nil in fetchPlacements closure")
                return
            }
            guard error == nil else {
                print("[PurchaseServiceLog] Error fetching paywalls: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            
            // Ищем плейсмент для пейвола
            if let paywallPlacement = placements.first(where: { $0.identifier == Config.payWallPlacement }),
               let paywall = paywallPlacement.paywall {
                self.paywallProducts = paywall.products
                
                // Get paywall type from JSON if available
                if let paywallType = paywall.json?["paywall"] as? Int {
                    DispatchQueue.main.async {
                        self.paywallType = paywallType != 1 ? 2 : 1
                    }
                }
                
                print("[PurchaseServiceLog] Loaded \(self.paywallProducts.count) paywall products from placement '\(Config.payWallPlacement)'")
            } else {
                print("[PurchaseServiceLog] No paywall placement found for \(Config.payWallPlacement)")
            }
            
            // Ищем плейсмент для триала (сохраняем на всякий случай)
            if let trialPlacement = placements.first(where: { $0.identifier == Config.trialPlacement }),
               let paywall = trialPlacement.paywall,
               let trialProduct = paywall.products.first {
                self.trialProduct = trialProduct
                print("[PurchaseServiceLog] Loaded trial product from placement '\(Config.trialPlacement)'")
            } else {
                print("[PurchaseServiceLog] No trial placement found for \(Config.trialPlacement)")
            }
        }
    }
    
    /// Покупка продукта по индексу
    /// Параметр `trialEnabled` – хотим ли мы использовать пробный период (если он доступен)
    @MainActor
    func purchase(productIndex: Int, trialEnabled: Bool) async -> Bool {
        guard productIndex < paywallProducts.count else {
            print("Нет продукта с индексом \(productIndex)")
            return false
        }
        let product = paywallProducts[productIndex]
        guard let skProduct = product.skProduct else {
            print("Отсутствует SKProduct у выбранного ApphudProduct")
            return false
        }
        
        return await withCheckedContinuation { continuation in
            if trialEnabled {
                Apphud.checkEligibilityForIntroductoryOffer(product: skProduct) { eligible in
                    print("Eligibility for trial: \(eligible)")
                    
                    Apphud.purchase(product) { result in
                        if let subscription = result.subscription, subscription.isActive() {
                            continuation.resume(returning: true)
                        } else {
                            continuation.resume(returning: false)
                        }
                    }
                }
            } else {
                Apphud.purchase(product) { result in
                    if let subscription = result.subscription, subscription.isActive() {
                        continuation.resume(returning: true)
                    } else {
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    }
    
    /// Формируем текстовую цену основного периода (например, "$4.99")
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
    
    /// Пример расчёта «старой цены» (если нужно показать зачёркнутую цену, например, 1.5x).
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
    
    /// Возвращаем цену и Locale, если нужно вручную что-то форматировать
    func productPriceAndLocale(for productIndex: Int) -> (NSDecimalNumber, Locale)? {
        guard productIndex < products.count,
              let skProduct = products[productIndex].skProduct
        else {
            return nil
        }
        return (skProduct.price, skProduct.priceLocale)
    }
    
    /// Получение срока подписки для отображения (сколько дней/недель/месяцев/лет)
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
        @unknown default:
            return NSLocalizedString("unknown", comment: "Unknown subscription period unit")
        }
    }
    
    /// Получение цены разбитой на мелкие промежутки
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
            let monthlyDays = 30.0 // приблизительно
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
        @unknown default:
            return NSLocalizedString("N/A", comment: "")
        }
    }
    
    // Восстановление покупок
    @MainActor
    func restorePurchases() async -> Bool {
        return await withCheckedContinuation { continuation in
            Apphud.restorePurchases { subscriptions, purchases, error in
                if let error = error {
                    print("Ошибка восстановления: \(error.localizedDescription)")
                    continuation.resume(returning: false)
                } else {
                    continuation.resume(returning: Apphud.hasActiveSubscription())
                }
            }
        }
    }
    
    func hasActiveSubscription() -> Bool {
        return Apphud.hasActiveSubscription()
    }
    
    // MARK: - Методы для trial-продукта (сохранены для обратной совместимости)
    
    @MainActor
    func purchaseTrialProduct() async -> Bool {
        guard let trialProduct = trialProduct else {
            print("[PurchaseServiceLog] No trial product available")
            return false
        }
        guard let skProduct = trialProduct.skProduct else {
            print("[PurchaseServiceLog] Trial product missing SKProduct")
            return false
        }
        
        return await withCheckedContinuation { continuation in
            Apphud.checkEligibilityForIntroductoryOffer(product: skProduct) { eligible in
                print("[PurchaseServiceLog] Eligibility for trial product: \(eligible)")
                
                Apphud.purchase(trialProduct) { result in
                    if let subscription = result.subscription, subscription.isActive() {
                        continuation.resume(returning: true)
                    } else {
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    }
    
    /// Текст цены для trial-продукта
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
    
    /// «Старая цена» для trial-продукта
    func oldPriceTextForTrial() -> String {
        guard let trialProduct = trialProduct,
              let skProduct = trialProduct.skProduct else {
            return NSLocalizedString("N/A", comment: "")
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = skProduct.priceLocale
        
        let multipliedPrice = skProduct.price.multiplying(by: NSDecimalNumber(value: 1.5))
        let multipliedDouble = multipliedPrice.doubleValue
        let integerPart = floor(multipliedDouble)
        var candidate = integerPart + 0.99
        if candidate < multipliedDouble {
            candidate = (integerPart + 1) + 0.99
        }
        let candidateDecimal = NSDecimalNumber(value: candidate)
        return formatter.string(from: candidateDecimal) ?? NSLocalizedString("N/A", comment: "")
    }
    
    /// Цена и Locale для trial-продукта
    func trialProductPriceAndLocale() -> (NSDecimalNumber, Locale)? {
        guard let trialProduct = trialProduct,
              let skProduct = trialProduct.skProduct else {
            return nil
        }
        return (skProduct.price, skProduct.priceLocale)
    }
    
    /// Описание срока подписки для trial-продукта
    func trialSubscriptionPeriodDescription() -> String {
        guard let trialProduct = trialProduct,
              let skProduct = trialProduct.skProduct,
              let period = skProduct.subscriptionPeriod
        else {
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
        @unknown default:
            return NSLocalizedString("unknown", comment: "Unknown subscription period unit")
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
            return period.numberOfUnits * 30  // приблизительно
        case .year:
            return period.numberOfUnits * 365 // приблизительно
        @unknown default:
            return nil
        }
    }
}
