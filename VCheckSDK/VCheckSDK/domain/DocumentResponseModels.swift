//
//  DocumentResponseModels.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 28.04.2022.
//

import Foundation



struct DocFieldWitOptPreFilledData {
    let name: String
    let title: DocTitle
    let type: String
    let regex: String?
    var autoParsedValue: String = ""
    
    func modifyAutoParsedValue(with: String) -> DocFieldWitOptPreFilledData {
        return DocFieldWitOptPreFilledData(name: name, title: title, type: type, regex: regex, autoParsedValue: with)
    }
}


struct DocumentUploadResponse: Codable {

  var data      : DocumentUploadResponseData? = nil
  var errorCode : Int?    = nil
  var message   : String? = nil

  enum CodingKeys: String, CodingKey {

    case data      = "data"
    case errorCode = "error_code"
    case message   = "message"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    data      = try values.decodeIfPresent(DocumentUploadResponseData.self , forKey: .data      )
    errorCode = try values.decodeIfPresent(Int.self    , forKey: .errorCode )
    message   = try values.decodeIfPresent(String.self , forKey: .message   )
 
  }

  init() {}

}



struct DocumentUploadResponseData: Codable {
    
    var id: Int? = nil
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
    }
    
    init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)
        
      id = try values.decodeIfPresent(Int.self, forKey: .id)
    }
}

// ----- COMMON / FOR COUNTRY

struct DocumentTypesForCountryResponse: Codable {

  var data      : [DocTypeData]? = []
  var errorCode : Int?    = nil
  var message   : String? = nil

  enum CodingKeys: String, CodingKey {
    case data      = "data"
    case errorCode = "error_code"
    case message   = "message"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
      
    data      = try values.decodeIfPresent([DocTypeData].self , forKey: .data      )
    errorCode = try values.decodeIfPresent(Int.self    , forKey: .errorCode )
    message   = try values.decodeIfPresent(String.self , forKey: .message   )
  }

  init() {}
}


struct DocTypeData: Codable {

  var auto          : Bool?     = nil
  var category      : Int?      = nil
  var country       : String?   = nil
  var fields        : [DocField]? = []
  var id            : Int?      = nil
  var maxPagesCount : Int?      = nil
  var minPagesCount : Int?      = nil

  enum CodingKeys: String, CodingKey {

    case auto          = "auto"
    case category      = "category"
    case country       = "country"
    case fields        = "fields"
    case id            = "id"
    case maxPagesCount = "max_pages_count"
    case minPagesCount = "min_pages_count"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    auto          = try values.decodeIfPresent(Bool.self     , forKey: .auto          )
    category      = try values.decodeIfPresent(Int.self      , forKey: .category      )
    country       = try values.decodeIfPresent(String.self   , forKey: .country       )
    fields        = try values.decodeIfPresent([DocField].self , forKey: .fields        )
    id            = try values.decodeIfPresent(Int.self      , forKey: .id            )
    maxPagesCount = try values.decodeIfPresent(Int.self      , forKey: .maxPagesCount )
    minPagesCount = try values.decodeIfPresent(Int.self      , forKey: .minPagesCount )
 
  }

  init() {}

}



struct DocField: Codable {

  var name  : String? = nil
  var regex : String? = nil
  var title : DocTitle?  = DocTitle()
  var type  : String? = nil

  enum CodingKeys: String, CodingKey {

    case name  = "name"
    case regex = "regex"
    case title = "title"
    case type  = "type"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    name  = try values.decodeIfPresent(String.self , forKey: .name  )
    regex = try values.decodeIfPresent(String.self , forKey: .regex )
    title = try values.decodeIfPresent(DocTitle.self  , forKey: .title )
    type  = try values.decodeIfPresent(String.self , forKey: .type  )
 
  }

  init() {}

}

struct DocTitle: Codable {

  var en : String? = nil
  var ru : String? = nil
  var uk : String? = nil

  enum CodingKeys: String, CodingKey {

    case en = "en"
    case ru = "ru"
    case uk = "uk"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    en = try values.decodeIfPresent(String.self , forKey: .en )
    ru = try values.decodeIfPresent(String.self , forKey: .ru )
    uk = try values.decodeIfPresent(String.self , forKey: .uk )
 
  }

  init() {}

}


// --- PRE-PROCESSED DOC

struct PreProcessedDocumentResponse: Codable {

  var data      : PreProcessedDocData?   = PreProcessedDocData()
  var errorCode : Int?    = nil
  var message   : String? = nil

  enum CodingKeys: String, CodingKey {

    case data      = "data"
    case errorCode = "error_code"
    case message   = "message"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    data      = try values.decodeIfPresent(PreProcessedDocData.self   , forKey: .data      )
    errorCode = try values.decodeIfPresent(Int.self    , forKey: .errorCode )
    message   = try values.decodeIfPresent(String.self , forKey: .message   )
 
  }

  init() {}

}


struct PreProcessedDocData: Codable {

  var id         : Int?        = nil
  var images     : [String]?   = []
  var isPrimary  : Bool?       = nil
  var parsedData : ParsedDocFieldsData? = ParsedDocFieldsData()
  var status     : Int?        = nil
  var type       : DocTypeData? = DocTypeData()

  enum CodingKeys: String, CodingKey {

    case id         = "id"
    case images     = "images"
    case isPrimary  = "is_primary"
    case parsedData = "parsed_data"
    case status     = "status"
    case type       = "type"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    id         = try values.decodeIfPresent(Int.self        , forKey: .id         )
    images     = try values.decodeIfPresent([String].self   , forKey: .images     )
    isPrimary  = try values.decodeIfPresent(Bool.self       , forKey: .isPrimary  )
    parsedData = try values.decodeIfPresent(ParsedDocFieldsData.self , forKey: .parsedData )
    status     = try values.decodeIfPresent(Int.self        , forKey: .status     )
    type       = try values.decodeIfPresent(DocTypeData.self       , forKey: .type       )
 
  }

  init() {}

}


struct ParsedDocFieldsData: Codable {

  var dateOfBirth  : String? = nil
  var dateOfExpiry : String? = nil
  var name         : String? = nil
  var number       : String? = nil
  var ogName       : String? = nil
  var ogSurname    : String? = nil
  var surname      : String? = nil

  enum CodingKeys: String, CodingKey {

    case dateOfBirth  = "date_of_birth"
    case dateOfExpiry = "date_of_expiry"
    case name         = "name"
    case number       = "number"
    case ogName       = "og_name"
    case ogSurname    = "og_surname"
    case surname      = "surname"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    dateOfBirth  = try values.decodeIfPresent(String.self , forKey: .dateOfBirth  )
    dateOfExpiry = try values.decodeIfPresent(String.self , forKey: .dateOfExpiry )
    name         = try values.decodeIfPresent(String.self , forKey: .name         )
    number       = try values.decodeIfPresent(String.self , forKey: .number       )
    ogName       = try values.decodeIfPresent(String.self , forKey: .ogName       )
    ogSurname    = try values.decodeIfPresent(String.self , forKey: .ogSurname    )
    surname      = try values.decodeIfPresent(String.self , forKey: .surname      )
 
  }

  init() {}

}


struct DocUserDataRequestBody: Codable {
    
    var user_data: ParsedDocFieldsData? = nil
    
    enum CodingKeys: String, CodingKey {
        case user_data  = "user_data"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        user_data = try values.decodeIfPresent(ParsedDocFieldsData.self , forKey: .user_data )
    }
    
    init(data: ParsedDocFieldsData) {
        self.user_data = data
    }
    
    init() {}
}
