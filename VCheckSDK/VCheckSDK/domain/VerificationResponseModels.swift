//
//  VerificationResponseModels.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 28.04.2022.
//

import Foundation


struct VerificationInitResponse: Codable {

  var data      : VerificationInitResponseData?   = VerificationInitResponseData()
  var errorCode : Int?    = nil
  var message   : String? = nil

  enum CodingKeys: String, CodingKey {

    case data      = "data"
    case errorCode = "error_code"
    case message   = "message"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    data      = try values.decodeIfPresent(VerificationInitResponseData.self   , forKey: .data      )
    errorCode = try values.decodeIfPresent(Int.self    , forKey: .errorCode )
    message   = try values.decodeIfPresent(String.self , forKey: .message   )
 
  }

  init() {}

}


struct VerificationInitResponseData: Codable {

  var id  : Int? = nil
  var status  : Int? = nil
  var locale    : String? = nil
  var returnUrl : String? = nil
  //removed "theme" property reading; not used in SDK ATM

  enum CodingKeys: String, CodingKey {

    case id    = "id"
    case status  = "status"
    case locale    = "locale"
    case returnUrl = "return_url"
  }

  init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)

      id   = try values.decodeIfPresent(Int.self , forKey: .id    )!
      status  = try values.decodeIfPresent(Int.self , forKey: .status  )!
      locale    = try values.decodeIfPresent(String.self , forKey: .locale    )
      returnUrl = try values.decodeIfPresent(String.self , forKey: .returnUrl )
    }

    init() {}

  }
