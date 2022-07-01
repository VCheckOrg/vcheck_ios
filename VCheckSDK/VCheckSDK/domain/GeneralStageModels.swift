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
    
    //Shuld be any object in future
    var config: String? = nil
    
    var primaryDocId: Int? = nil // for DOCUMENT UPLOAD stage only
    var uploadedDocId: Int? = nil // for DOCUMENT UPLOAD stage only

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
        config  = try values.decodeIfPresent(String.self    , forKey: .config )
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
