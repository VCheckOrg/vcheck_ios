import Foundation

enum VCheckSDKConstants {
    
    enum API {
        static let devVerificationApiBaseUrl = URL(string: "https://test-verification.vycheck.com/api/v1/")!
        static let partnerVerificationApiBaseUrl = URL(string: "https://verification.vycheck.com/api/v1/")!
        
        static let devVerificationServiceUrl = "https://test-verification.vycheck.com"
        static let partnerVerificationServiceUrl = "https://verification.vycheck.com"
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
