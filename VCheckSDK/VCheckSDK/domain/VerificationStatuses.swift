//
//  VerificationStatuses.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 12.09.2022.
//

import Foundation

class VerificationStatuses {
    
    static let CREATED = 0
    static let INITIALIZED = 1
    static let WAITING_USER_INTERACTION = 2
    static let WAITING_POSTPROCESSING = 3
    static let IN_POSTPROCESSING = 4
    static let WAITING_MANUAL_CHECK = 5
    static let FINALIZED = 6
}
