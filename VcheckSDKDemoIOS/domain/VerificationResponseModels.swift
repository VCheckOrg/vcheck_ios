//
//  VerificationResponseModels.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 28.04.2022.
//

import Foundation


import Foundation

struct VerificationCreateAttemptResponse: Codable {

  var data      : VerificationCreateAttemptResponseData?   = VerificationCreateAttemptResponseData()
  var errorCode : Int?    = nil
  var message   : String? = nil

  enum CodingKeys: String, CodingKey {

    case data      = "data"
    case errorCode = "error_code"
    case message   = "message"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    data      = try values.decodeIfPresent(VerificationCreateAttemptResponseData.self   , forKey: .data      )
    errorCode = try values.decodeIfPresent(Int.self    , forKey: .errorCode )
    message   = try values.decodeIfPresent(String.self , forKey: .message   )
 
  }

  init() {}

}


struct VerificationCreateAttemptResponseData: Codable {

  var applicationId : Int?    = nil
  var createTime    : String? = nil
  var redirectUrl   : String? = nil
  var token         : String? = nil

  enum CodingKeys: String, CodingKey {

    case applicationId = "application_id"
    case createTime    = "create_time"
    case redirectUrl   = "redirect_url"
    case token = "token"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    applicationId = try values.decodeIfPresent(Int.self    , forKey: .applicationId )
    createTime    = try values.decodeIfPresent(String.self , forKey: .createTime    )
    redirectUrl   = try values.decodeIfPresent(String.self , forKey: .redirectUrl   )
    token         = try values.decodeIfPresent(String.self , forKey: .token   )
 
  }

  init() {}

}



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

  var config    : Config? = Config()
  var document  : String? = nil
  var locale    : String? = nil
  var returnUrl : String? = nil
  var stage     : Int?    = nil
  var livenessAttempts: Int? = nil

  enum CodingKeys: String, CodingKey {

    case config    = "config"
    case document  = "document"
    case locale    = "locale"
    case returnUrl = "return_url"
    case stage     = "stage"
    case livenessAttempts = "liveness_attempts"
  }

  init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)

      config    = try values.decodeIfPresent(Config.self , forKey: .config    )
      document  = try values.decodeIfPresent(String.self , forKey: .document  )
      locale    = try values.decodeIfPresent(String.self , forKey: .locale    )
      returnUrl = try values.decodeIfPresent(String.self , forKey: .returnUrl )
      stage     = try values.decodeIfPresent(Int.self    , forKey: .stage     )
      livenessAttempts = try values.decodeIfPresent(Int.self, forKey: .livenessAttempts)
    }

    init() {}

  }


struct Config: Codable {

  var theme : String? = nil

  enum CodingKeys: String, CodingKey {

    case theme = "theme"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    theme = try values.decodeIfPresent(String.self , forKey: .theme )
 
  }

  init() {}

}

