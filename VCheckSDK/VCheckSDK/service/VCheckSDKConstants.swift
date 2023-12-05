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
    
    static let vcheckDefaultThemeConfig: String =
     """
     {
       "primary": "#2E75FF",
       "primaryHover": "#2E96FF",
       "primaryActive": "#3361EC",
       "primaryContent": "#FFFFFF",
       "primaryBg": "#5D6884",
       "accent": "#6096FF",
       "accentHover": "#6ABFFF",
       "accentActive": "#4F79F7",
       "accentContent": "#FFFFFF",
       "accentBg": "#32404A",
       "neutral": "#FFFFFF",
       "neutralHover": "rgba(255, 255, 255, 0.4)",
       "neutralActive": "rgba(255, 255, 255, 0.1)",
       "neutralContent": "#000000",

       "success": "#6CFB93",
       "successHover": "#C8FDD2",
       "successActive": "#00DF53",
       "successBg": "#3A4B3F",
       "successContent": "#3B3B3B",
       "error": "#F47368",
       "errorHover": "#FF877C",
       "errorActive": "#DE473A",
       "errorBg": "#4B2A24",
       "errorContent": "#3B3B3B",
       "warning": "#FFB482",
       "warningHover": "#FFBF94",
       "warningActive": "#D3834E",
       "warningBg": "#3F3229",
       "warningContent": "#3B3B3B",

       "base": "#2A2A2A",
       "base_100": "#3C3C3C",
       "base_200": "#555555",
       "base_300": "#6A6A6A",
       "base_400": "#7F7F7F",
       "base_500": "#949494",
       "baseContent": "#FFFFFF",
       "baseSecondaryContent": "#D8D8D8",
       "disabled": "#AAAAAA",
       "disabledContent": "#6A6A6A"
     }
     """
}
