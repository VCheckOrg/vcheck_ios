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
    private var verificationToken: String? = nil
    
    private var selectedCountryCode: String? = nil
    
    private var verificationType: VerificationSchemeType?
    private var partnerUserId: String? = nil
    private var partnerVerificationId: String? = nil
    private var sessionLifetime: Int? = nil
    
    internal var verificationClientCreationModel: VerificationClientCreationModel? = nil
    
    private var sdkLanguageCode: String? = nil
    
    internal var showPartnerLogo: Bool = false
    internal var showCloseSDKButton: Bool = true
    
    ///Nav properties:
    private var partnerAppRootWindow: UIWindow? = nil
    private var partnerAppViewController: UIViewController? = nil
    private var changeRootViewController: Bool? = nil
    
    ///Color customization properties:
    internal var buttonsColorHex: String? = nil
    internal var backgroundPrimaryColorHex: String? = nil
    internal var backgroundSecondaryColorHex: String? = nil
    internal var backgroundTertiaryColorHex: String? = nil
    internal var primaryTextColorHex: String? = nil
    internal var secondaryTextColorHex: String? = nil
    internal var borderColorHex: String? = nil
    private let wrongColorFormatPickDescr: String = "VCheckSDK - error: if provided, " +
            "custom color should be a valid HEX string (RGB or ARGB). Ex.: '#2A2A2A' or '#abdbe3'"
    

    public func start(partnerAppRW: UIWindow,
                      partnerAppVC: UIViewController,
                      replaceRootVC: Bool) {
        
        self.resetVerification()
        
        self.partnerAppRootWindow = partnerAppRW
        self.partnerAppViewController = partnerAppVC
        self.changeRootViewController = replaceRootVC
        
        if (preStartChecksPassed()) {
                        
            self.verificationClientCreationModel =
                VerificationClientCreationModel.init(partnerId: self.partnerId!,
                                                    partnerSecret: self.partnerSecret!,
                                                    verificationType: self.verificationType!,
                                                    partnerUserId: self.partnerUserId,
                                                    partnerVerificationId: self.partnerVerificationId,
                                                    sessionLifetime: self.sessionLifetime)
            
            if (self.changeRootViewController == false) {
                partnerAppViewController!.present(GlobalUtils.getVCheckHomeVC(), animated: true)
            } else {
                partnerAppRootWindow!.rootViewController = GlobalUtils.getVCheckHomeVC()
                partnerAppRootWindow!.makeKeyAndVisible()
            }
        }
    }
    
    private func resetVerification() {
        VCheckSDKLocalDatasource.shared.resetSessionData()
        self.verificationId = nil
        self.verificationToken = nil
        self.selectedCountryCode = nil
    }
    
    internal func finish(executePartnerCallback: Bool) {
        if (self.changeRootViewController == true) {
            partnerAppRootWindow!.rootViewController = partnerAppViewController
            partnerAppRootWindow!.makeKeyAndVisible()
        }
        if (executePartnerCallback == true) {
            self.partnerEndCallback!()
        }
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
        if (sdkLanguageCode == nil) {
           print("VCheckSDK - warning: sdk language code is not set; using English (en) locale as default. " +
                            "| see VCheckSDK.sdkLanguageCode(langCode: String)")
        }
        if (sdkLanguageCode != nil && !VCheckSDKConstants
                .vcheckSDKAvailableLanguagesList.contains((sdkLanguageCode?.lowercased())!)) {
            print("VCheckSDK - error: SDK is not localized with [$sdkLanguageCode] locale yet. " +
                    "You may set one of the next locales: ${VCheckSDKConstantsProvider.vcheckSDKAvailableLanguagesList}, " +
                    "or check out for the recent version of the SDK library")
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
        if (buttonsColorHex != nil && !buttonsColorHex!.isValidHexColor()) {
            print(wrongColorFormatPickDescr)
            return false
        }
        if (backgroundPrimaryColorHex != nil && !backgroundPrimaryColorHex!.isValidHexColor()) {
            print(wrongColorFormatPickDescr)
            return false
        }
        if (backgroundSecondaryColorHex != nil && !backgroundSecondaryColorHex!.isValidHexColor()) {
            print(wrongColorFormatPickDescr)
            return false
        }
        if (backgroundTertiaryColorHex != nil && !backgroundTertiaryColorHex!.isValidHexColor()) {
            print(wrongColorFormatPickDescr)
            return false
        }
        if (primaryTextColorHex != nil && !primaryTextColorHex!.isValidHexColor()) {
            print(wrongColorFormatPickDescr)
            return false
        }
        if (secondaryTextColorHex != nil && !secondaryTextColorHex!.isValidHexColor()) {
            print(wrongColorFormatPickDescr)
            return false
        }
        if (borderColorHex != nil && !borderColorHex!.isValidHexColor()) {
            print(wrongColorFormatPickDescr)
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
    
    public func languageCode(langCode: String) -> VCheckSDK {
        self.sdkLanguageCode = langCode.lowercased()
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
        VCheckSDKRemoteDatasource.shared.checkFinalVerificationStatus(verifId: self.verificationId!,
                                                             partnerId: self.partnerId!,
                                                             partnerSecret: self.partnerSecret!,
                                                             completion: { (response, error) in
            if let error = error {
                completion(nil, error)
            }
            if let response = response {
                if (response.data != nil) {
                    let result = VerificationCheckResult.init(fromData: response.data!)
                    completion(result, nil)
                } else {
                    print("VCheckSDK - error: no data response received from checkFinalVerificationStatus request!")
                }
            }
        })
    }
    
    internal func setVerificationToken(token: String) {
        self.verificationToken = token
    }

    internal func getVerificationToken() -> String {
        if (verificationToken == nil) {
            print("VCheckSDK - error: verification token is not set!")
        }
        return verificationToken ?? ""
    }
    
    internal func setVerificationId(verifId: Int) {
        self.verificationId = verifId
    }


    private func getVerificationId() -> Int {
        if (verificationId == nil) {
            print("VCheckSDK - error: verification id is not set!")
        }
        return verificationId ?? -1
    }

    public func getSDKLangCode() -> String {
        return sdkLanguageCode ?? "en"
    }

    internal func getSelectedCountryCode() -> String {
        return selectedCountryCode ?? "ua"
    }

    internal func setSelectedCountryCode(code: String) {
        self.selectedCountryCode = code
    }
    
    ///Color public customization methods:
    
    public func colorActionButtons(colorHex: String) -> VCheckSDK {
        self.buttonsColorHex = colorHex
        return self
    }

    public func colorBackgroundPrimary(colorHex: String) -> VCheckSDK {
        self.backgroundPrimaryColorHex = colorHex
        return self
    }

    public func colorBackgroundSecondary(colorHex: String) -> VCheckSDK {
        self.backgroundSecondaryColorHex = colorHex
        return self
    }

    public func colorBackgroundTertiary(colorHex: String) -> VCheckSDK {
        self.backgroundTertiaryColorHex = colorHex
        return self
    }

    public func colorTextPrimary(colorHex: String) -> VCheckSDK {
        self.primaryTextColorHex = colorHex
        return self
    }

    public func colorTextSecondary(colorHex: String) -> VCheckSDK {
        self.secondaryTextColorHex = colorHex
        return self
    }

    public func colorBorders(colorHex: String) -> VCheckSDK {
        self.borderColorHex = colorHex
        return self
    }

    func resetCustomColors() {
        self.buttonsColorHex = nil
        self.backgroundPrimaryColorHex = nil
        self.backgroundSecondaryColorHex = nil
        self.backgroundTertiaryColorHex = nil
        self.primaryTextColorHex = nil
        self.secondaryTextColorHex = nil
        self.borderColorHex = nil
    }
    
    /// Other public methods for customization
    
    public func getPartnerAppViewController() -> UIViewController? {
        return self.partnerAppViewController
    }
    
    func showPartnerLogo(show: Bool) -> VCheckSDK {
        self.showPartnerLogo = show
        return self
    }

    func showCloseSDKButton(show: Bool) -> VCheckSDK {
        self.showCloseSDKButton = show
        return self
    }
}
