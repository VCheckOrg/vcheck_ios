//
//  VerificationRequestModels.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 28.04.2022.
//

import Foundation

struct CreateVerificationRequestBody: Codable {

  var locale               : String? = nil
  var partnerApplicationId : String? = nil
  var partnerId            : Int?    = nil
  var partnerUserId        : String? = nil
  var sign                 : String? = nil
  var timestamp            : Int?    = nil

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

    locale               = try values.decodeIfPresent(String.self , forKey: .locale               )
    partnerApplicationId = try values.decodeIfPresent(String.self , forKey: .partnerApplicationId )
    partnerId            = try values.decodeIfPresent(Int.self    , forKey: .partnerId            )
    partnerUserId        = try values.decodeIfPresent(String.self , forKey: .partnerUserId        )
    sign                 = try values.decodeIfPresent(String.self , forKey: .sign                 )
    timestamp            = try values.decodeIfPresent(Int.self    , forKey: .timestamp            )
 
  }

  init() {

  }

}
