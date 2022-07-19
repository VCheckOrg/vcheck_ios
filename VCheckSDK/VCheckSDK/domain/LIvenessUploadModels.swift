//
//  LIvenessUploadModels.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 08.06.2022.
//

import Foundation


struct LivenessGestureResponse: Codable {

  var success   : Bool? = nil
  var errorCode : Int?    = nil
  var message   : String? = nil

  enum CodingKeys: String, CodingKey {

    case success  = "data"
    case errorCode = "error_code"
    case message   = "message"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    success   = try values.decodeIfPresent(Bool.self , forKey: .success    )
    errorCode = try values.decodeIfPresent(Int.self    , forKey: .errorCode )
    message   = try values.decodeIfPresent(String.self , forKey: .message   )
  }

  init() {
  }

}


struct LivenessUploadResponse: Codable {

  var data      : LivenessUploadResponseData? = nil
  var errorCode : Int?    = nil
  var message   : String? = nil

  enum CodingKeys: String, CodingKey {

    case data      = "data"
    case errorCode = "error_code"
    case message   = "message"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    data      = try values.decodeIfPresent(LivenessUploadResponseData.self , forKey: .data      )
    errorCode = try values.decodeIfPresent(Int.self    , forKey: .errorCode )
    message   = try values.decodeIfPresent(String.self , forKey: .message   )
  }

  init() {
  }

}


struct LivenessUploadResponseData: Codable {

  var isFinal : Bool?   = nil
  var reason  : String? = nil
  var status  : Int?    = nil

  enum CodingKeys: String, CodingKey {

    case isFinal = "is_final"
    case reason  = "reason"
    case status  = "status"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    isFinal = try values.decodeIfPresent(Bool.self   , forKey: .isFinal )
    reason  = try values.decodeIfPresent(String.self , forKey: .reason  )
    status  = try values.decodeIfPresent(Int.self    , forKey: .status  )
  }

  init() {
  }

}


enum LivenessChallengeStatus {
    case INITIALIZED
    case RUNNING
    case SUCCESS
    case FAIL
}

func statusCodeToLivenessChallengeStatus(code: Int) -> LivenessChallengeStatus {
    switch (code) {
        case 0: return LivenessChallengeStatus.INITIALIZED
        case 1: return LivenessChallengeStatus.RUNNING
        case 2: return LivenessChallengeStatus.SUCCESS
        case 3: return LivenessChallengeStatus.FAIL
        default: return LivenessChallengeStatus.FAIL
    }
}

func livenessChallengeStatusToCode(livenessChallengeStatus: LivenessChallengeStatus) -> Int {
    switch (livenessChallengeStatus) {
        case LivenessChallengeStatus.INITIALIZED: return 0
        case LivenessChallengeStatus.RUNNING: return 1
        case LivenessChallengeStatus.SUCCESS: return 2
        case LivenessChallengeStatus.FAIL: return 3
    }
}

enum LivenessFailureReason: String, CaseIterable {
    case FACE_NOT_FOUND = "face_not_found"
    case MULTIPLE_FACES = "multiple_faces"
    case FAST_MOVEMENT = "fast_movement"
    case TOO_DARK = "too_dark"
    case INVALID_MOVEMENTS = "invalid_movements"
    case UNKNOWN = "unknown"

    
    static func from(type: String?) -> LivenessFailureReason {
        return LivenessFailureReason.allCases.first(where: {
            $0.rawValue.lowercased() == type?.lowercased() } ) ?? LivenessFailureReason.UNKNOWN
    }
}

func strCodeToLivenessFailureReason(strCode: String) -> LivenessFailureReason {
    return LivenessFailureReason.from(type: strCode)
}

func livenessFailureReasonToStrCode(r: LivenessFailureReason) -> String {
    return r.rawValue.lowercased()
}
