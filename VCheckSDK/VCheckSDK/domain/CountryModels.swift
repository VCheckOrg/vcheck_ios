//
//  CountryModels.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 28.04.2022.
//

import Foundation

struct CountryTO {
    
    var name: String
    var code: String
    var flag: String
    var isBlocked: Bool
    
    init(from countryCode: String) {
        self.isBlocked = false
        self.code = countryCode
        self.name = CountryTO.countryName(countryCode: countryCode)
        self.flag = CountryTO.strToFlagEmoji(from: countryCode)
    }
    
    static func countryName(countryCode: String) -> String {
        let current = Locale(identifier: VCheckSDK.shared.getSDKLangCode())
        return current.localizedString(forRegionCode: countryCode) ?? "Not Localized"
    }
    
    static func strToFlagEmoji(from country:String) -> String {
        let base : UInt32 = 127397
        var s = ""
        for v in country.uppercased().unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return s
    }
}
