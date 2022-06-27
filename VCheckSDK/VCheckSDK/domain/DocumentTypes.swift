//
//  DocumentTypes.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 30.04.2022.
//

import Foundation


enum DocType {
    case INNER_PASSPORT_OR_COMMON
    case FOREIGN_PASSPORT
    case ID_CARD
}

extension DocType {
    
    func toCategoryIdx() -> Int {
        switch(self) {
            case DocType.INNER_PASSPORT_OR_COMMON: return 0
            case DocType.FOREIGN_PASSPORT: return 1
            case DocType.ID_CARD: return 2
        }
    }

    static func docCategoryIdxToType(categoryIdx: Int) -> DocType {
        switch(categoryIdx) {
            case 0: return DocType.INNER_PASSPORT_OR_COMMON
            case 1: return DocType.FOREIGN_PASSPORT
            case 2: return DocType.ID_CARD
            default: return DocType.INNER_PASSPORT_OR_COMMON
        }
    }
}


