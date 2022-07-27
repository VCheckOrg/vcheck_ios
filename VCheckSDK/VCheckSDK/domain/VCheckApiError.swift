//
//  ApiError.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 08.06.2022.
//

import Foundation

public struct VCheckApiError {
    
    static let DEFAULT_CODE: Int = 0
    
    let errorText: String
    let errorCode: Int?
    let data: Any? = nil
}
