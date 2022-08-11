import Foundation

enum VCheckSDKConstants {
    
    enum API {
        static let verificationApiBaseUrl = URL(string: "https://test-verification.vycheck.com/api/v1/")!
        static let partnerApiBaseUrl = URL(string: "https://test-partner.vycheck.com/v1/")!
        static let defaultSessionLifetime = 3600
    }
    
    enum UTIL {
        static let keychainAccountName = "vcheck"
    }
    
    static let vcheckSDKAvailableLanguagesList: [String] = [
                "uk",
                "en",
                "ru",
                "pl"
    ]
}
