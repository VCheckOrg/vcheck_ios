//
//  DocumentRequestModels.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 27.07.2022.
//

import Foundation


struct DocUserDataRequestBody: Codable {
    
    var user_data: ParsedDocFieldsData? = nil
    var is_forced: Bool? = nil
    
    enum CodingKeys: String, CodingKey {
        case user_data  = "user_data"
        case is_forced = "is_forced"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        user_data = try values.decodeIfPresent(ParsedDocFieldsData.self , forKey: .user_data )
        is_forced = try values.decodeIfPresent(Bool.self, forKey: .is_forced)
    }
    
    init(data: ParsedDocFieldsData, isForced: Bool) {
        self.user_data = data
        self.is_forced = isForced
    }
    
    init() {}
}
