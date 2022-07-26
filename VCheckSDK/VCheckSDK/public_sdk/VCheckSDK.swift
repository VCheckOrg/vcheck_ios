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
    
    private var verificationId: Int? = nil
    
    private var verificationType: VerificationSchemeType?
    private var partnerUserId: String? = nil
    private var partnerVerificationId: String? = nil
    private var sessionLifetime: Int? = nil
    
    internal var verificationClientCreationModel: VerificationClientCreationModel? = nil
    

    public func start(partnerAppRootWindow: UIWindow) {
        
        if (preStartChecksPassed()) {
            
            GlobalUtils.setVCheckCurrentLanguageCode(langCode: Locale.current.languageCode!)
            
            self.verificationClientCreationModel = VerificationClientCreationModel.init(partnerId: self.partnerId!,
                                                                                        partnerSecret: self.partnerSecret!,
                                                                                        verificationType: self.verificationType!,
                                                                                        partnerUserId: self.partnerUserId,
                                                                                        partnerVerificationId: self.partnerVerificationId,
                                                                                        sessionLifetime: self.sessionLifetime)
            
            partnerAppRootWindow.rootViewController = GlobalUtils.getVCheckHomeVC()
            partnerAppRootWindow.makeKeyAndVisible()
        }
    }
    
    public func onFinish() {
        self.partnerEndCallback!()
    }
    
    private func preStartChecksPassed() -> Bool {
        if (self.verificationType == nil) {
            print("VCheckSDK - error: proper verification type must be provided | see VCheckSDK.shared.verificationType(type: VerificationSchemeType)")
            return false
        }
        if (self.partnerEndCallback == nil) {
           print("VCheckSDK - error: partner application's callback function (invoked on SDK flow finish) must be provided | see VCheckSDK.shared.partnerSecret(secret: String)")
           return false
        }
        if (self.partnerId == nil) {
           print("VCheckSDK - error: partner ID must be provided | see VCheckSDK.shared.verificationType(type: VerificationSchemeType)")
           return false
        }
        if (self.partnerSecret == nil) {
           print("VCheckSDK - error: partner secret must be provided by client app | see VCheckSDK.shared.partnerSecret(secret: String)")
           return false
        }
        if (self.partnerUserId != nil && partnerUserId!.isEmpty) {
           print("VCheckSDK - error: if provided, partner user ID must be unique to your service and not empty")
           return false
        }
        if (self.partnerVerificationId != nil && partnerVerificationId!.isEmpty) {
           print("VCheckSDK - error: if provided, partner verification ID must be unique to your service and not empty")
           return false
        }
        if (self.sessionLifetime != nil && sessionLifetime! < 300) {
           print("VCheckSDK - error: if provided, custom session lifetime should not be less than 300 seconds")
           return false
        }
        return true
    }
    
    public func partnerEndCallback(callback: (() -> Void)?) -> VCheckSDK {
        self.partnerEndCallback = callback
        return self
    }
    
    public func partnerId(id: Int) -> VCheckSDK {
        self.partnerId = id
        return self
    }

    public func partnerSecret(secret: String) -> VCheckSDK {
        self.partnerSecret = secret
        return self
    }

    public func verificationType(type: VerificationSchemeType) -> VCheckSDK {
        self.verificationType = type
        return self
    }

    public func partnerUserId(pUID: String) -> VCheckSDK {
        self.partnerUserId = pUID
        return self
    }

    public func partnerVerificationId(pVerId: String) -> VCheckSDK {
        self.partnerVerificationId = pVerId
        return self
    }

    public func sessionLifetime(lifetime: Int) -> VCheckSDK {
        self.sessionLifetime = lifetime
        return self
    }
    
    public func checkFinalVerificationStatus(completion:
                                             @escaping (VerificationCheckResult?, VCheckApiError?) -> ()) {
        RemoteDatasource.shared.checkFinalVerificationStatus(verifToken: LocalDatasource.shared.readAccessToken(),
                                                             verifId: self.verificationId!,
                                                             partnerId: self.partnerId!,
                                                             partnerSecret: self.partnerSecret!,
                                                             completion: { (result, error) in
            if let error = error {
                completion(nil, error)
            }
            completion(result, nil)
        })
    }
}


//private var customServiceURL: String? = nil

//    if (customServiceURL != nil && !customServiceURL!.isValidURL()) {
//       print("VCheckSDK - error: if provided, custom service URL must be valid public URL")
//       return false
//    }

//    func customServiceURL(url: String) -> VCheckSDK {
//        self.customServiceURL = url
//        return self
//    }
