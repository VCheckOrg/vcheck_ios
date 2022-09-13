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
    
    private var verificationToken: String? = nil

    private var verificationType: VerificationSchemeType?
    
    private var selectedCountryCode: String? = nil
    
    private var sdkLanguageCode: String? = nil
    
    private var environment: VCheckEnvironment? = nil
    
    ///iOS nav properties:
    private var partnerAppRootWindow: UIWindow? = nil
    internal var partnerAppViewController: UIViewController? = nil
    internal var changeRootViewController: Bool? = nil
    
    ///Color and UI customization properties:
    internal var showPartnerLogo: Bool = false
    internal var showCloseSDKButton: Bool = true
    
    internal var iconsColorHex: String? = nil
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
        self.selectedCountryCode = nil
    }
    
    internal func finish(executePartnerCallback: Bool) {
        
        VCheckSDKLocalDatasource.shared.resetSessionData()
        self.selectedCountryCode = nil
        
        if (self.changeRootViewController == true) {
            partnerAppRootWindow!.rootViewController = partnerAppViewController
            partnerAppRootWindow!.makeKeyAndVisible()
        } else {
            partnerAppRootWindow!.rootViewController?.dismiss(animated: true, completion: {})
            partnerAppRootWindow!.rootViewController?.navigationController?.popViewController(animated: true)
        }
        if (executePartnerCallback == true) {
            self.partnerEndCallback!()
        }
    }
    
    private func preStartChecksPassed() -> Bool {
        if (verificationToken == nil) {
            print("VCheckSDK - error: proper verification token must be provided | see VCheckSDK.shared.verificationToken(token: String)")
            return false
        }
        if (self.verificationType == nil) {
            print("VCheckSDK - error: proper verification type must be provided | see VCheckSDK.shared.verificationType(type: VerificationSchemeType)")
            return false
        }
        if (self.partnerEndCallback == nil) {
           print("VCheckSDK - error: partner application's callback function (invoked on SDK flow finish) must be provided | see VCheckSDK.shared.partnerSecret(secret: String)")
           return false
        }
        if (self.sdkLanguageCode == nil) {
           print("VCheckSDK - warning: sdk language code is not set; using English (en) locale as default. " +
                            "| see VCheckSDK.shared.sdkLanguageCode(langCode: String)")
        }
        if (self.sdkLanguageCode != nil && !VCheckSDKConstants
                .vcheckSDKAvailableLanguagesList.contains((self.sdkLanguageCode?.lowercased())!)) {
            print("VCheckSDK - error: SDK is not localized with [$sdkLanguageCode] locale yet. " +
                    "You may set one of the next locales: ${VCheckSDKConstantsProvider.vcheckSDKAvailableLanguagesList}, " +
                    "or check out for the recent version of the SDK library")
            return false
        }
        if (environment == nil) {
            print("VCheckSDK - warning: sdk environment is not set; using DEV environment by default " +
                             "| see VCheckSDK.shared.environment(env: VCheckEnvironment)")
            return false
        }
        if (self.buttonsColorHex != nil && !self.buttonsColorHex!.isValidHexColor()) {
            print(wrongColorFormatPickDescr)
            return false
        }
        if (self.backgroundPrimaryColorHex != nil && !self.backgroundPrimaryColorHex!.isValidHexColor()) {
            print(wrongColorFormatPickDescr)
            return false
        }
        if (self.backgroundSecondaryColorHex != nil && !self.backgroundSecondaryColorHex!.isValidHexColor()) {
            print(wrongColorFormatPickDescr)
            return false
        }
        if (self.backgroundTertiaryColorHex != nil && !self.backgroundTertiaryColorHex!.isValidHexColor()) {
            print(wrongColorFormatPickDescr)
            return false
        }
        if (self.primaryTextColorHex != nil && !self.primaryTextColorHex!.isValidHexColor()) {
            print(wrongColorFormatPickDescr)
            return false
        }
        if (self.secondaryTextColorHex != nil && !self.secondaryTextColorHex!.isValidHexColor()) {
            print(wrongColorFormatPickDescr)
            return false
        }
        if (self.borderColorHex != nil && !self.borderColorHex!.isValidHexColor()) {
            print(wrongColorFormatPickDescr)
            return false
        }
        if (self.iconsColorHex != nil && !self.iconsColorHex!.isValidHexColor()) {
            print(wrongColorFormatPickDescr)
            return false
        }
        return true
    }
    
    public func partnerEndCallback(callback: (() -> Void)?) -> VCheckSDK {
        self.partnerEndCallback = callback
        return self
    }
    
    public func verificationToken(token: String) -> VCheckSDK {
        self.verificationToken = token
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

    public func getVerificationType() -> VerificationSchemeType? {
        return self.verificationType
    }

    public func getVerificationToken() -> String {
        if (verificationToken == nil) {
            print("VCheckSDK - error: verification token is not set!")
        }
        return verificationToken!
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
    
    public func colorIcons(colorHex: String) -> VCheckSDK {
        self.iconsColorHex = colorHex
        return self
    }

    func resetCustomColors() {
        self.iconsColorHex = nil
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
    
    public func showPartnerLogo(show: Bool) -> VCheckSDK {
        self.showPartnerLogo = show
        return self
    }

    public func showCloseSDKButton(show: Bool) -> VCheckSDK {
        self.showCloseSDKButton = show
        return self
    }
    
    public func environment(env: VCheckEnvironment) -> VCheckSDK {
        self.environment = env
        return self
    }
    
    internal func getEnvironment() -> VCheckEnvironment {
        return self.environment ?? VCheckEnvironment.DEV
    }
}
