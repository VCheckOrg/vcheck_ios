//
//  InitVerficationCodes.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 14.09.2023.
//

import Foundation

//TODO: make enum with int values?
enum InitVerificationResponseCode {
    case VERIFICATION_NOT_INITIALIZED
    case PROVIDER_NOT_FOUND
    case COUNTRY_NOT_FOUND
    case PROVIDER_ALREADY_INITIALIZED
}

extension InitVerificationResponseCode {
    func toCodeIdx() -> Int {
        switch(self) {
            case InitVerificationResponseCode.VERIFICATION_NOT_INITIALIZED: return 0
            case InitVerificationResponseCode.PROVIDER_NOT_FOUND: return 1
            case InitVerificationResponseCode.COUNTRY_NOT_FOUND: return 2
            case InitVerificationResponseCode.PROVIDER_ALREADY_INITIALIZED: return 3
        }
    }
}

func codeIdxToVerificationCode(codeIdx: Int) -> InitVerificationResponseCode {
    switch(codeIdx) {
        case 0: return InitVerificationResponseCode.VERIFICATION_NOT_INITIALIZED
        case 1: return InitVerificationResponseCode.PROVIDER_NOT_FOUND
        case 2: return InitVerificationResponseCode.COUNTRY_NOT_FOUND
        case 3: return InitVerificationResponseCode.PROVIDER_ALREADY_INITIALIZED
        default: return InitVerificationResponseCode.VERIFICATION_NOT_INITIALIZED
    }
}
