//
//  Constants.swift
//  APIClient-Example
//
//  Created by Roman Kyrylenko on 1/23/18.
//  Copyright © 2018 Yalantis. All rights reserved.
//

import Foundation

enum Constants {
    
    enum API {

        static let verificationApiBaseUrl = URL(string: "https://test-verification.vycheck.com/api/v1/")!
        static let partnerApiBaseUrl = URL(string: "https://test-partner.vycheck.com/api/v1/")!
        static let defaultSessionLifetime = 3600
    }
    
    enum UTIL {
        
        static let keychainAccountName = "vhcheck"
    }
}
