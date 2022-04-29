//
//  CountryModels.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 28.04.2022.
//

import Foundation


struct CountriesResponse: Codable {

  var data      : [Country]? = []
  var errorCode : Int?    = nil
  var message   : String? = nil

  enum CodingKeys: String, CodingKey {

    case data      = "data"
    case errorCode = "error_code"
    case message   = "message"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    data      = try values.decodeIfPresent([Country].self , forKey: .data      )
    errorCode = try values.decodeIfPresent(Int.self    , forKey: .errorCode )
    message   = try values.decodeIfPresent(String.self , forKey: .message   )
 
  }

  init() {

  }

}


struct Country: Codable {

  var code      : String
  var isBlocked : Bool

  enum CodingKeys: String, CodingKey {

    case code      = "code"
    case isBlocked = "is_blocked"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    code      = try values.decodeIfPresent(String.self , forKey: .code      )!
    isBlocked = try values.decodeIfPresent(Bool.self   , forKey: .isBlocked )!
 
  }

}


struct CountryTO {
    
    var name: String
    var code: String
    var flag: String
    var isBlocked: Bool
    
    init(from country: Country) {
        self.isBlocked = country.isBlocked
        self.code = country.code
        self.name = CountryTO.countryName(countryCode: country.code)
        self.flag = CountryTO.strToFlagEmoji(from: country.code)
    }
    
    static func countryName(countryCode: String) -> String {
        let current = Locale(identifier: Locale.current.identifier)
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
    
//    static func strToFlagEmoji(strCode: String) -> String {
//        strCode
//            .unicodeScalars
//            .map({ 127397 + $0.value })
//            .compactMap(UnicodeScalar.init)
//            .map(String.init)
//            .joined()
//    }
}
