//
//  GeeneralStageModels.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 01.07.2022.
//

import Foundation

struct StageResponse: Codable {

  var data      : StageResponseData? = nil
  var errorCode : Int?    = nil
  var message   : String? = nil

  enum CodingKeys: String, CodingKey {

    case data      = "data"
    case errorCode = "error_code"
    case message   = "message"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    data      = try values.decodeIfPresent(StageResponseData.self , forKey: .data      )
    errorCode = try values.decodeIfPresent(Int.self    , forKey: .errorCode )
    message   = try values.decodeIfPresent(String.self , forKey: .message   )
  }

  init() {
  }

    init(data: StageResponseData, errorCode: Int?, message: String?) {
        self.data = data
        self.errorCode = errorCode
        self.message = message
    }
}


struct StageResponseData: Codable {
    
    var id: Int? = nil
    var type: Int? = nil
    var config: LivenessStageConfig? = nil //Curretly using only for Liveness purposes
    
    var primaryDocId: Int? = nil // optional; for DOCUMENT UPLOAD stage only
    var uploadedDocId: Int? = nil // optional; for DOCUMENT UPLOAD stage only

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case type  = "type"
        case config  = "config"
        
        case primaryDocId = "primary_document_id"
        case uploadedDocId = "uploaded_document_id"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        id = try values.decodeIfPresent(Int.self   , forKey: .id )
        type  = try values.decodeIfPresent(Int.self , forKey: .type )
        config  = try values.decodeIfPresent(LivenessStageConfig.self    , forKey: .config )
        primaryDocId  = try values.decodeIfPresent(Int.self    , forKey: .primaryDocId  )
        uploadedDocId  = try values.decodeIfPresent(Int.self    , forKey: .uploadedDocId  )
    }

    init() {
    }
    
    init(id: Int, type: Int) {
        self.id = id
        self.type = type
    }
}


enum StageErrorType {
    case VERIFICATION_NOT_INITIALIZED
    case USER_INTERACTED_COMPLETED
    case VERIFICATION_EXPIRED
}

extension StageErrorType {
    
    func toTypeIdx() -> Int {
        switch(self) {
            case StageErrorType.VERIFICATION_NOT_INITIALIZED: return 0
            case StageErrorType.USER_INTERACTED_COMPLETED: return 1
            case StageErrorType.VERIFICATION_EXPIRED: return 2
        }
    }

    static func idxToType(categoryIdx: Int) -> StageErrorType {
        switch(categoryIdx) {
            case 0: return StageErrorType.VERIFICATION_NOT_INITIALIZED
            case 1: return StageErrorType.USER_INTERACTED_COMPLETED
            case 2: return StageErrorType.VERIFICATION_EXPIRED
            default: return StageErrorType.VERIFICATION_NOT_INITIALIZED
        }
    }
}


struct LivenessStageConfig: Codable {

  var gestures : [String]? = []

  enum CodingKeys: String, CodingKey {

    case gestures = "gestures"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    gestures = try values.decodeIfPresent([String].self , forKey: .gestures )
  }

  init() {}

}




enum StageType {
    case DOCUMENT_UPLOAD// = 0
    case LIVENESS_CHALLENGE// = 1
    //IDENTITY_VERIFICATION = 2 - should not interact with front-end
}

extension StageType {
    
    func toTypeIdx() -> Int {
        switch(self) {
            case StageType.DOCUMENT_UPLOAD: return 0
            case StageType.LIVENESS_CHALLENGE: return 1
        }
    }

    static func idxToType(categoryIdx: Int) -> StageType {
        switch(categoryIdx) {
            case 0: return StageType.DOCUMENT_UPLOAD
            case 1: return StageType.LIVENESS_CHALLENGE
            default: return StageType.DOCUMENT_UPLOAD
        }
    }
}
