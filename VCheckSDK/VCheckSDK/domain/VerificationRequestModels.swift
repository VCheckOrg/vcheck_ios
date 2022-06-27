//
//  VerificationRequestModels.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 28.04.2022.
//

import Foundation

struct CreateVerificationRequestBody: Codable {

    var partnerId            : Int    = 1
    var partnerApplicationId : String = currentTimeInMilliSecondsStr()
    var partnerUserId        : String = currentTimeInMilliSecondsStr()
    var locale               : String = "ua"
    var timestamp            : Int    = Int(Date().timeIntervalSince1970)
    var sign                 : String = "-"

  enum CodingKeys: String, CodingKey {

    case locale               = "locale"
    case partnerApplicationId = "partner_application_id"
    case partnerId            = "partner_id"
    case partnerUserId        = "partner_user_id"
    case sign                 = "sign"
    case timestamp            = "timestamp"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    locale               = try values.decodeIfPresent(String.self , forKey: .locale               )!
    partnerApplicationId = try values.decodeIfPresent(String.self , forKey: .partnerApplicationId )!
    partnerId            = try values.decodeIfPresent(Int.self    , forKey: .partnerId            )!
    partnerUserId        = try values.decodeIfPresent(String.self , forKey: .partnerUserId        )!
    sign                 = try values.decodeIfPresent(String.self , forKey: .sign                 )!
    timestamp            = try values.decodeIfPresent(Int.self    , forKey: .timestamp            )!
  }

  init(ts: String, locale: String) {
      
      //self.timestamp = Int(timestamp)
      self.locale = locale
      
      print("TIMESTAMP : \(String(describing: ts))")
      
      //let i: Int = Int(ts)! as Int
      
      let secondPrecision = Int(Date().timeIntervalSince1970)
      self.timestamp = secondPrecision
      print("SELF TIMESTAMP : \(String(describing: self.timestamp))")
      
      let testSecret = Constants.API.testPartnerSecret
      let strToSign = "\(self.partnerApplicationId)\(self.partnerId)\(self.partnerUserId)\(self.timestamp)\(testSecret)"
      self.sign = strToSign.sha256()
      
//      let tss = Int64(ts)
//      print("SELF TIMESTAMP : \(String(describing: tss))")
      
  }
}

extension CreateVerificationRequestBody {
    
    static func currentTimeInMilliSecondsStr() -> String {
            let currentDate = Date()
            let since1970 = currentDate.timeIntervalSince1970
        return "\(Int(since1970 * 1000))"
    }
}
