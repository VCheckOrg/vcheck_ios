//
//  VerificationSchemes.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 07.07.2022.
//

import Foundation

public enum VerificationSchemeType: String, CustomStringConvertible {
    case FULL_CHECK// = «full_check»
    case DOCUMENT_UPLOAD_ONLY// = «document_upload_only»
    case LIVENESS_CHALLENGE_ONLY// = «liveness_challenge_only»
    
    public var description: String {
        get {
            return self.rawValue.lowercased()
        }
    }
}
