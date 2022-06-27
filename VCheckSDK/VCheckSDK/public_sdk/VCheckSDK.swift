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
    
    private var finishSDKFlowCallback : (() -> Void)?
    
    public func start(partnerAppRootWindow: UIWindow?,
                             partnerCallbackOnVerifSuccess: (() -> Void)?) {
        
        self.finishSDKFlowCallback = partnerCallbackOnVerifSuccess
        
        GlobalUtils.setVCheckCurrentLanguageCode(langCode: Locale.current.languageCode!)
        
        partnerAppRootWindow?.rootViewController = GlobalUtils.getVCheckHomeVC()
        partnerAppRootWindow?.makeKeyAndVisible()
    }
    
    public func onFinish() {
        self.finishSDKFlowCallback!()
    }
    
}
