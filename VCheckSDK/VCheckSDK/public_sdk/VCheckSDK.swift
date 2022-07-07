//
//  VCheckSDK.swift
//  VcheckFramework
//
//  Created by Kirill Kaun on 21.06.2022.
//

import Foundation
import UIKit

public class VCheckSDK {
    
    public static let shared = VCheckSDK()
    
    private var partnerEndCallback: (() -> Void)? = nil
        
    private var partnerId: Int? = nil
    private var partnerSecret: String? = nil
    
    private var verificationType: VerificationSchemeType = VerificationSchemeType.FULL_CHECK
    private var partnerUserId: String? = nil
    private var partnerVerificationId: String? = nil
    private var customServiceURL: String? = nil
    private var sessionLifetime: Int? = nil

    
    public func start(partnerAppRootWindow: UIWindow) {
        
        if (preStartChecksPassed()) {
            GlobalUtils.setVCheckCurrentLanguageCode(langCode: Locale.current.languageCode!)
            
            partnerAppRootWindow.rootViewController = GlobalUtils.getVCheckHomeVC()
            partnerAppRootWindow.makeKeyAndVisible()
        }
    }
    
    public func onFinish() {
        self.partnerEndCallback!()
    }
    
    private func preStartChecksPassed() -> Bool {
        if (partnerEndCallback == nil) {
           print("VCheckSDK - error: partner application's callback function (invoked on SDK flow finish) must be provided | see VheckSDK.shared.partnerSecret(secret: String)")
           return false
        }
        if (partnerId == nil) {
           print("VCheckSDK - error: partner ID must be provided | see VCheckSDK.shared.verificationType(type: VerificationSchemeType)")
           return false
        }
        if (partnerSecret == nil) {
           print("VCheckSDK - error: partner secret must be provided by client app | see VCheckSDK.shared.partnerSecret(secret: String)")
           return false
        }
        if (partnerUserId != nil && partnerUserId!.isEmpty) {
           print("VCheckSDK - error: if provided, partner user ID must be unique to your service and not empty")
           return false
        }
        if (partnerVerificationId != nil && partnerVerificationId!.isEmpty) {
           print("VCheckSDK - error: if provided, partner verification ID must be unique to your service and not empty")
           return false
        }
        if (customServiceURL != nil && !customServiceURL!.isValidURL()) {
           print("VCheckSDK - error: if provided, custom service URL must be valid public URL")
           return false
        }
        if (sessionLifetime != nil && sessionLifetime! < 300) {
           print("VCheckSDK - error: if provided, custom session lifetime should not be less than 300 seconds")
           return false
        }
        return true
    }
    
    func partnerEndCallback(callback: (() -> Void)?) -> VCheckSDK {
        self.partnerEndCallback = callback
        return self
    }
    
    func partnerId(id: Int) -> VCheckSDK {
        self.partnerId = id
        return self
    }

    func partnerSecret(secret: String) -> VCheckSDK {
        self.partnerSecret = secret
        return self
    }

    func verificationType(type: VerificationSchemeType) -> VCheckSDK {
        self.verificationType = type
        return self
    }

    func partnerUserId(pUID: String) -> VCheckSDK {
        self.partnerUserId = pUID
        return self
    }

    func partnerVerificationId(pVerId: String) -> VCheckSDK {
        self.partnerVerificationId = pVerId
        return self
    }

    func customServiceURL(url: String) -> VCheckSDK {
        self.customServiceURL = url
        return self
    }

    func sessionLifetime(lifetime: Int) -> VCheckSDK {
        self.sessionLifetime = lifetime
        return self
    }
    
}
