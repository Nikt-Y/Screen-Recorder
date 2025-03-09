import Foundation

struct Config {
    static let appId = "6741587360"
    static let bundleId = "authenticator.security.cod"
//    static let extensionBundleId = "<YOUR-EXTENSION-BUNDLE-ID>"
//    static let appGroupId = "<YOUR-APP-GROUP-ID>"
    
    // Apphud
    static let apphud = "app_FxEUxMgSdE4m4V968quosEd1z29RAU"
    static let payWallPlacement = "main"
    static let trialPlacement = "trial"
    
    // Privacy & Terms
    static let privacyPolicyURL = URL(string: "https://docs.google.com/document/d/1nq_H_ft0fEpKl-r9R6EMkCyAb86pYOguYzK656CPCs8/edit?usp=sharing")
    static let termsOfUseURL = URL(string: "https://docs.google.com/document/d/17Wp8g8hk3ecbzh64N1aM9w2v07ygAEgT_RhakYgM2rc/edit?usp=sharing")
    
    // Email
    static let supportEmail = "rozinskidamian4@gmail.com"
    
    // Share
    static let shareText = String(format: NSLocalizedString("I highly recommend using Authenticator for secure authentication! Download it here: %@", comment: ""), "https://apps.apple.com/app/id6741587360")
}
