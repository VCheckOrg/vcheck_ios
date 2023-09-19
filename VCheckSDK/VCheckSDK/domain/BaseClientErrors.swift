//
//  BaseClientErrors.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 14.07.2023.
//

import Foundation

class BaseClientErrors {
    
    static let VERIFICATION_NOT_INITIALIZED = 0
    static let USER_INTERACTED_COMPLETED = 1
    static let STAGE_NOT_FOUND = 2
    static let INVALID_STAGE_TYPE = 3
    static let PRIMARY_DOCUMENT_EXISTS_OR_USER_INTERACTION_COMPLETED = 4
    static let UPLOAD_ATTEMPTS_EXCEEDED = 5
    static let INVALID_DOCUMENT_TYPE = 6
    static let INVALID_PAGES_COUNT = 7
    static let INVALID_FILES = 8
    static let PHOTO_TOO_LARGE = 9
    static let PARSING_ERROR = 10
    static let INVALID_PAGE = 11
}
