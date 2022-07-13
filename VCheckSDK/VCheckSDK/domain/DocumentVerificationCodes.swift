//
//  DocumentVerificationCodes.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 06.05.2022.
//

import Foundation

enum DocumentVerificationCode {
    
    case VERIFICATION_NOT_INITIALIZED// = 0
    case USER_INTERACTED_COMPLETED// = 1
    case STAGE_NOT_FOUND// = 2
    case INVALID_STAGE_TYPE// = 3
    case PRIMARY_DOCUMENT_EXISTS// = 4
    case UPLOAD_ATTEMPTS_EXCEEDED// = 5
    case INVALID_DOCUMENT_TYPE// = 6
    case INVALID_PAGES_COUNT// = 7
    case INVALID_FILES// = 8
    case PHOTO_TOO_LARGE// = 9
    case PARSING_ERROR// = 10
}

extension DocumentVerificationCode {
    func toCodeIdx() -> Int {
        switch(self) {
            case DocumentVerificationCode.VERIFICATION_NOT_INITIALIZED: return 0
            case DocumentVerificationCode.USER_INTERACTED_COMPLETED: return 1
            case DocumentVerificationCode.STAGE_NOT_FOUND: return 2
            case DocumentVerificationCode.INVALID_STAGE_TYPE: return 3
            case DocumentVerificationCode.PRIMARY_DOCUMENT_EXISTS: return 4
            case DocumentVerificationCode.UPLOAD_ATTEMPTS_EXCEEDED: return 5
            case DocumentVerificationCode.INVALID_DOCUMENT_TYPE: return 6
            case DocumentVerificationCode.INVALID_PAGES_COUNT: return 7
            case DocumentVerificationCode.INVALID_FILES: return 8
            case DocumentVerificationCode.PHOTO_TOO_LARGE: return 9
            case DocumentVerificationCode.PARSING_ERROR: return 10
        }
    }
}

func codeIdxToVerificationCode(codeIdx: Int) -> DocumentVerificationCode {
    switch(codeIdx) {
        case 0: return DocumentVerificationCode.VERIFICATION_NOT_INITIALIZED
        case 1: return DocumentVerificationCode.USER_INTERACTED_COMPLETED
        case 2: return DocumentVerificationCode.STAGE_NOT_FOUND
        case 3: return DocumentVerificationCode.INVALID_STAGE_TYPE
        case 4: return DocumentVerificationCode.PRIMARY_DOCUMENT_EXISTS
        case 5: return DocumentVerificationCode.UPLOAD_ATTEMPTS_EXCEEDED
        case 6: return DocumentVerificationCode.INVALID_DOCUMENT_TYPE
        case 7: return DocumentVerificationCode.INVALID_PAGES_COUNT
        case 8: return DocumentVerificationCode.INVALID_FILES
        case 9: return DocumentVerificationCode.PHOTO_TOO_LARGE
        default: return DocumentVerificationCode.PARSING_ERROR
    }
}


//    case OK //0
//    case InvalidPagesCount  //1 - Неверное кол-во загруженных файлов
//    case InvalidVerificationStage  //2 - Этап заявки не соответствует разрешенному для данного запроса
//    case UploadAttemptsExceeded  //3 - Кол-во попыток на загрузку истекло
//    case InvalidFiles //4 - Неверное расширение документа
//    case InvalidDocumentType //5 - Неверный тип документа
//    case PrimaryAlreadyExists  //6 - Основой документ уже существует
//    case PhotoTooLarge //7 - Вес файлов превышает допустимый
