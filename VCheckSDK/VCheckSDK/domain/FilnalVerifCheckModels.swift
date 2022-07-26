//
//  FilnalVerifCheckModels.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 26.07.2022.
//

import Foundation


public struct VerificationCheckResult {
    var isFinalizedAndSuccessful: Bool = false
    var isFinalizedAndFailed: Bool = false
    var isWaitingForManualCheck: Bool = false
    var status: String
    var scheme: String
    var createdAt: String?
    var finalizedAt: String?
    var rejectionReasons: [String]?
    
    init(fromData: FinalVerifCheckResponseData) {
        
        let isFinalizedAndSuccess: Bool = (fromData.status?.lowercased() == "finalized" && fromData.isSuccess == true)
        let isFinalizedAndFailed: Bool = (fromData.status?.lowercased() == "finalized" && fromData.isSuccess == false)
        let waitingForManualcheck: Bool = fromData.status?.lowercased() == "waiting_manual_check"
        
        self.isFinalizedAndSuccessful = isFinalizedAndSuccess
        self.isFinalizedAndFailed = isFinalizedAndFailed
        self.isWaitingForManualCheck = waitingForManualcheck
        
        self.status = fromData.status!
        self.scheme = fromData.scheme!
        self.createdAt = fromData.createdAt
        self.finalizedAt = fromData.finalizedAt
        self.rejectionReasons = fromData.rejectionReasons
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


/*
 data class VerificationResult(
     val isFinalizedAndSuccessful: Boolean,
     val isFinalizedAndFailed: Boolean,
     val isWaitingForManualCheck: Boolean,
     val status: String,
     val scheme: String,
     val createdAt: String?,
     val finalizedAt: String?,
     val rejectionReasons: List<String>?
 )

 data class FinalVerifCheckResponseModel(
     @SerializedName("data")
     val data: FinalVerifCheckResponseData,
     @SerializedName("error_code")
     var errorCode: Int = 0,
     @SerializedName("message")
     var message: String = ""
 )

 data class FinalVerifCheckResponseData(
     @SerializedName("status")
     val status: String,
     @SerializedName("is_success")
     val isSuccess: Boolean?,
     @SerializedName("scheme")
     val scheme: String,
     @SerializedName("created_at")
     val createdAt: String,
     @SerializedName("finalized_at")
     val finalizedAt: String?,
     @SerializedName("rejection_reasons")
     val rejectionReasons: List<String>?
 )
 */
