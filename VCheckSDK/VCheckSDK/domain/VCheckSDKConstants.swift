import Foundation

enum VCheckSDKConstants {
    
    enum API {
        static let devVerificationApiBaseUrl = URL(string: "https://test-verification.vycheck.com/api/v1/")!
        static let partnerVerificationApiBaseUrl = URL(string: "https://verification.vycheck.com/api/v1/")!
        //static let defaultSessionLifetime = 3600
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
