//
//  FilnalVerifCheckModels.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 26.07.2022.
//

import Foundation


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
                
        let isFinalizedAndSuccess: Bool = (fromData.status?.lowercased() == "finalized" && fromData.isSuccess == true)
        let isFinalizedAndFailed: Bool = (fromData.status?.lowercased() == "finalized" && fromData.isSuccess == false)
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
