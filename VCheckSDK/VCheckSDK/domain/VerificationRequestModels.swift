//
//  VerificationRequestModels.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 28.04.2022.
//

import Foundation

struct CreateVerificationRequestBody: Codable {

    var partnerId: Int
    var timestamp: Int  // Int(Date().timeIntervalSince1970)
    var scheme: String
    var locale: String
    var partnerUserId: String?
    var partnerVerificationId : String?
    var callbackUrl: String?
    var sessionLifetime: Int?
    var sign: String

  enum CodingKeys: String, CodingKey {

    case locale               = "locale"
    case partnerVerificationId = "partner_verification_id"
    case partnerId            = "partner_id"
    case partnerUserId        = "partner_user_id"
    case sign                 = "sign"
    case timestamp            = "timestamp"
    case scheme               = "scheme"
    case callbackUrl          = "callback_url"
    case sessionLifetime      = "session_lifetime"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    locale                  = try values.decodeIfPresent(String.self , forKey: .locale               )!
    partnerVerificationId   = try values.decodeIfPresent(String.self , forKey: .partnerVerificationId)!
    partnerId               = try values.decodeIfPresent(Int.self    , forKey: .partnerId            )!
    partnerUserId           = try values.decodeIfPresent(String.self , forKey: .partnerUserId        )!
    sign                    = try values.decodeIfPresent(String.self , forKey: .sign                 )!
    timestamp               = try values.decodeIfPresent(Int.self    , forKey: .timestamp            )!
    scheme                  = try values.decodeIfPresent(String.self , forKey: .scheme               )!
    callbackUrl             = try values.decodeIfPresent(String.self , forKey: .callbackUrl          )!
    sessionLifetime         = try values.decodeIfPresent(Int.self    , forKey: .sessionLifetime      )!
  }

    init(ts: String, locale: String, vModel: VerificationClientCreationModel) {
        
        let partnerId = vModel.partnerId
        let partnerSecret = vModel.partnerSecret
        let scheme = vModel.verificationType.description
        let partnerUserId = vModel.partnerUserId ?? CreateVerificationRequestBody.currentTimeInMilliSecondsStr()
        let partnerVerificationId = vModel.partnerVerificationId ?? CreateVerificationRequestBody.currentTimeInMilliSecondsStr()
        var callbackUrl = ""
        if (vModel.customServiceURL != nil) {
            callbackUrl = vModel.customServiceURL!
        }
        else {
            callbackUrl = "\(Constants.API.verificationApiBaseUrl)ping"
        }
        let sessionLifetime = vModel.sessionLifetime ?? Constants.API.defaultSessionLifetime
              
        self.partnerId = partnerId
        self.timestamp = Int(ts)!
        self.scheme = scheme
        self.locale = locale
        self.partnerUserId = partnerUserId
        self.partnerVerificationId = partnerVerificationId
        self.callbackUrl = callbackUrl
        self.sessionLifetime = sessionLifetime
      
        let strToSign = "\(self.partnerId)\(self.partnerUserId)\(self.partnerVerificationId)\(self.scheme)\(self.timestamp)\(partnerSecret)"
        self.sign = strToSign.sha256()
      
    //'partner_id'+'partner_user_id'+'partner_verification_id'+'scheme'+'timestamp'+'secret' !!!
        
    //self.timestamp = Int(timestamp)
    //      let secondPrecision = Int(Date().timeIntervalSince1970)
    //      self.timestamp = secondPrecision
    //      print("SELF TIMESTAMP : \(String(describing: self.timestamp))")
  }
}

extension CreateVerificationRequestBody {
    
    static func currentTimeInMilliSecondsStr() -> String {
            let currentDate = Date()
            let since1970 = currentDate.timeIntervalSince1970
        return "\(Int(since1970 * 1000))"
    }
}
