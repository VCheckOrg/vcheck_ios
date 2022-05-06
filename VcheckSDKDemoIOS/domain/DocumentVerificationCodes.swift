//
//  DocumentVerificationCodes.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 06.05.2022.
//

import Foundation

enum DocumentVerificationCode {
    case OK //0
    case InvalidPagesCount  //1 - Неверное кол-во загруженных файлов
    case InvalidVerificationStage  //2 - Этап заявки не соответствует разрешенному для данного запроса
    case UploadAttemptsExceeded  //3 - Кол-во попыток на загрузку истекло
    case InvalidFiles //4 - Неверное расширение документа
    case InvalidDocumentType //5 - Неверный тип документа
    case PrimaryAlreadyExists  //6 - Основой документ уже существует
    case PhotoTooLarge //7 - Вес файлов превышает допустимый
}

extension DocumentVerificationCode {
    func toCodeIdx() -> Int {
        switch(self) {
            case DocumentVerificationCode.OK: return 0
            case DocumentVerificationCode.InvalidPagesCount: return 1
            case DocumentVerificationCode.InvalidVerificationStage: return 2
            case DocumentVerificationCode.UploadAttemptsExceeded: return 3
            case DocumentVerificationCode.InvalidFiles: return 4
            case DocumentVerificationCode.InvalidDocumentType: return 5
            case DocumentVerificationCode.PrimaryAlreadyExists: return 6
            case DocumentVerificationCode.PhotoTooLarge: return 7
        }
    }
}

func codeIdxToVerificationCode(codeIdx: Int) -> DocumentVerificationCode {
    switch(codeIdx) {
        case 0: return DocumentVerificationCode.OK
        case 1: return DocumentVerificationCode.InvalidPagesCount
        case 2: return DocumentVerificationCode.InvalidVerificationStage
        case 3: return DocumentVerificationCode.UploadAttemptsExceeded
        case 4: return DocumentVerificationCode.InvalidFiles
        case 5: return DocumentVerificationCode.InvalidDocumentType
        case 6: return DocumentVerificationCode.PrimaryAlreadyExists
        default: return DocumentVerificationCode.PhotoTooLarge
    }
}


