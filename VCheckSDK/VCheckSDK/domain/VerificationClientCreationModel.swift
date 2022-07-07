//
//  VerificationClientCreationModel.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 07.07.2022.
//

import Foundation


struct VerificationClientCreationModel {
    
    let partnerId: Int
    let partnerSecret: String
    var verificationType: VerificationSchemeType = VerificationSchemeType.FULL_CHECK
    var partnerUserId: String? = nil
    var partnerVerificationId: String? = nil
    var customServiceURL: String? = nil
    var sessionLifetime: Int? = nil
}
