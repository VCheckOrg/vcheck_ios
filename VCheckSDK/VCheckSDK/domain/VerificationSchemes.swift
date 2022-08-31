//
//  VerificationSchemes.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 07.07.2022.
//

import Foundation

public enum VerificationSchemeType: String, CustomStringConvertible {
    case FULL_CHECK
    case DOCUMENT_UPLOAD_ONLY
    case LIVENESS_CHALLENGE_ONLY
    
    public var description: String {
        get {
            return self.rawValue.lowercased()
        }
    }
}

public enum VCheckEnvironment {
    case PARTNER
    case DEV
}
