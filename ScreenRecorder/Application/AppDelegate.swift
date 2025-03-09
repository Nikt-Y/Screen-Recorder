import SwiftUI
//import UserNotifications
import ApphudSDK
//import Firebase

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        for family in UIFont.familyNames {
            print("Family: \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("  Font: \(name)")
            }
        }
        
//        Apphud.start(apiKey: Config.apphud)
        PurchaseService.shared.loadProducts()
        
        return true
    }
}
