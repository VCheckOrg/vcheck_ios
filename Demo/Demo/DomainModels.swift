//
//  DomainModels.swift
//  Demo
//
//  Created by Kirill Kaun on 28.12.2023.
//

import Foundation
import VCheckSDK

public struct PartnerApplicationRequestData: Codable {

  var company   : String? = nil
  var email : String?    = nil
  var name   : String? = nil
  var phone: String? = nil

  public enum CodingKeys: String, CodingKey {

    case email  = "email"
    case company = "company"
    case phone   = "phone"
    case name = "name"
  
  }

  public init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      
      company   = try values.decodeIfPresent(String.self , forKey: .company   )
      email   = try values.decodeIfPresent(String.self , forKey: .email   )
      name   = try values.decodeIfPresent(String.self , forKey: .name   )
      phone   = try values.decodeIfPresent(String.self , forKey: .phone   )
  }

  public init() {
  }
    
    public init(company: String, email: String, name: String, phone: String?) {
        self.email = email
        self.company = company
        self.name = name
        self.phone = phone
    }

}



struct VerificationClientCreationModel {
    
    let partnerId: Int
    let partnerSecret: String
    let verificationType: VerificationSchemeType
    var partnerUserId: String? = nil
    var partnerVerificationId: String? = nil
    var sessionLifetime: Int? = nil
}



public struct VerificationCheckResult {
    private(set) var isFinalizedAndSuccess: Bool? = nil
    private(set) var isFinalizedAndFail: Bool? = nil
    private(set) var isWaitForManualCheck: Bool? = nil
    private(set) var status: String
    private(set) var scheme: String
    private(set) var createdAt: String?
    private(set) var finalizedAt: String?
    private(set) var rejectionReasons: [String]?
    
    init(fromData: FinalVerifCheckResponseData) {
                
        let isFinalizedAndSuccess: Bool = (fromData.status?.lowercased() == "completed" && fromData.isSuccess == true)
        let isFinalizedAndFailed: Bool = (fromData.status?.lowercased() == "completed" && fromData.isSuccess == false)
        let waitingForManualCheck: Bool = fromData.status?.lowercased() == "waiting_manual_check"
        
        self.isFinalizedAndSuccess = isFinalizedAndSuccess
        self.isFinalizedAndFail = isFinalizedAndFailed
        self.isWaitForManualCheck = waitingForManualCheck
        
        self.status = fromData.status!
        self.scheme = fromData.scheme!
        self.createdAt = fromData.createdAt
        self.finalizedAt = fromData.finalizedAt
        self.rejectionReasons = fromData.rejectionReasons
    }
    
    public func isFinalizedAndSuccessful() -> Bool {
        return self.isFinalizedAndSuccess ?? false
    }
    
    public func isFinalizedAndFailed() -> Bool {
        return self.isFinalizedAndFail ?? false
    }
    
    public func isWaitingForManualCheck() -> Bool {
        return self.isWaitForManualCheck ?? false
    }
    
    public func getStatus() -> String {
        return self.status
    }
    
    public func getScheme() -> String {
        return self.scheme
    }
    
    public func getCreationTimeStr() -> String? {
        return self.createdAt
    }
    
    public func getFinalizationTimeStr() -> String? {
        return self.finalizedAt
    }
    
    public func getRejectionReasons() -> [String]? {
        return self.rejectionReasons
    }
}


struct FinalVerifCheckResponseModel: Codable {

  var data      : FinalVerifCheckResponseData? = nil
  var errorCode : Int?    = nil
  var message   : String? = nil

  enum CodingKeys: String, CodingKey {

    case data      = "data"
    case errorCode = "error_code"
    case message   = "message"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    data      = try values.decodeIfPresent(FinalVerifCheckResponseData.self , forKey: .data      )
    errorCode = try values.decodeIfPresent(Int.self    , forKey: .errorCode )
    message   = try values.decodeIfPresent(String.self , forKey: .message   )
  }

  init() {
  }

    init(data: FinalVerifCheckResponseData, errorCode: Int?, message: String?) {
        self.data = data
        self.errorCode = errorCode
        self.message = message
    }
}


struct FinalVerifCheckResponseData: Codable {
    
    var status: String? = nil
    var isSuccess: Bool? = nil
    var scheme: String? = nil
    var createdAt: String? = nil
    var finalizedAt: String? = nil
    var rejectionReasons: [String]? = nil
    
    enum CodingKeys: String, CodingKey {

      case status    = "status"
      case isSuccess = "is_success"
      case scheme   = "scheme"
      case createdAt = "created_at"
      case finalizedAt = "finalized_at"
      case rejectionReasons = "rejection_reasons"
    
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        status      = try values.decodeIfPresent(String.self , forKey: .status  )
        isSuccess = try values.decodeIfPresent(Bool.self    , forKey: .isSuccess )
        scheme   = try values.decodeIfPresent(String.self , forKey: .scheme  )
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        finalizedAt = try values.decodeIfPresent(String.self, forKey: .finalizedAt)
        rejectionReasons = try values.decodeIfPresent([String].self, forKey: .rejectionReasons)
    }

    init() {
    }
}


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

  var id        : Int?    = nil
  var url       : String? = nil
  var token     : String? = nil

  enum CodingKeys: String, CodingKey {

    case id = "id"
    case url   = "url"
    case token = "token"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    id      = try values.decodeIfPresent(Int.self    , forKey: .id )
    url     = try values.decodeIfPresent(String.self , forKey: .url   )
    token   = try values.decodeIfPresent(String.self , forKey: .token   )
 
  }

  init() {}

}


struct CreateVerificationRequestBody: Codable {

    var partnerId: Int
    var timestamp: Int
    var scheme: String
    var locale: String
    var partnerUserId: String
    var partnerVerificationId : String
    var callbackUrl: String
    var sessionLifetime: Int
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

    init(ts: String, locale: String, scheme: String) {
        
        let partnerUserId: String = CreateVerificationRequestBody.currentTimeInMilliSecondsStr()
        let partnerVerificationId: String = CreateVerificationRequestBody.currentTimeInMilliSecondsStr()
        let callbackUrl: String = "\(RemoteDatasource.verifBaseUrl)ping"
        let sessionLifetime: Int = 3600
              
        self.partnerId = LocalDatasource.shared.getPartnerId() ?? 0
        let partnerSecret = LocalDatasource.shared.getSecret()
        
        self.timestamp = Int(ts)! //TODO: handle wrong format
        self.scheme = scheme
        self.locale = locale
        self.partnerUserId = partnerUserId
        self.partnerVerificationId = partnerVerificationId
        self.callbackUrl = callbackUrl
        self.sessionLifetime = sessionLifetime
      
        let strToSign = "\(self.partnerId)\(self.partnerUserId)\(self.partnerVerificationId)\(self.scheme)\(self.timestamp)\(partnerSecret!)"
                
        self.sign = strToSign.sha256()
  }
}

extension CreateVerificationRequestBody {
    
    static func currentTimeInMilliSecondsStr() -> String {
            let currentDate = Date()
            let since1970 = currentDate.timeIntervalSince1970
        return "\(Int(since1970 * 1000))"
    }
}
