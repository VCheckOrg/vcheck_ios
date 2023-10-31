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
    
    private var onVerificationExpired: (() -> Void)? = nil
    private var isVerifExpired: Bool = false
    
    private var verificationToken: String? = nil

    private var verificationType: VerificationSchemeType?
    
    private var selectedProvider: Provider? = nil
    private var providerLogicCase: ProviderLogicCase? = nil
    private var allAvailableProviders: [Provider]? = nil
    
    private var optSelectedCountryCode: String? = nil
    
    private var sdkLanguageCode: String? = nil
    
    private var environment: VCheckEnvironment? = nil
    
    ///iOS nav properties:
    private var partnerAppRootWindow: UIWindow? = nil
    internal var partnerAppViewController: UIViewController? = nil
    internal var changeRootViewController: Bool? = nil
    
    ///Color and UI customization properties:
    internal var showPartnerLogo: Bool = false
    internal var showCloseSDKButton: Bool = true
    
    internal var designConfig: VCheckDesignConfig? = nil

    public func start(partnerAppRW: UIWindow,
                      partnerAppVC: UIViewController,
                      replaceRootVC: Bool) {
        
        self.resetVerification()
        
        self.partnerAppRootWindow = partnerAppRW
        self.partnerAppViewController = partnerAppVC
        self.changeRootViewController = replaceRootVC
        
        do {
            try makePreStartChecks()
            
            if (self.changeRootViewController == false) {
                partnerAppViewController!.present(GlobalUtils.getVCheckHomeVC(), animated: true)
            } else {
                partnerAppRootWindow!.rootViewController = GlobalUtils.getVCheckHomeVC()
                partnerAppRootWindow!.makeKeyAndVisible()
            }
        } catch {
            
        }
    }
    
    private func resetVerification() {
        VCheckSDKLocalDatasource.shared.resetCache()
        self.optSelectedCountryCode = nil
        self.isVerifExpired = false
    }
    
    internal func finish(executePartnerCallback: Bool) {
        VCheckSDKLocalDatasource.shared.resetCache()
        self.optSelectedCountryCode = nil
        
        if (self.changeRootViewController == true) {
            partnerAppRootWindow!.rootViewController = partnerAppViewController
            partnerAppRootWindow!.makeKeyAndVisible()
        } else {
            partnerAppRootWindow!.rootViewController?.dismiss(animated: true, completion: {})
            partnerAppRootWindow!.rootViewController?.navigationController?.popViewController(animated: true)
        }
        if (self.isVerifExpired == true) {
            self.onVerificationExpired!()
        } else {
            if (executePartnerCallback == true) {
                self.partnerEndCallback!()
            }
        }
    }
    
    private func makePreStartChecks() throws {
        if (self.environment == nil) {
            print("VCheckSDK - warning: sdk environment is not set by partner developer | see VCheckSDK.shared.environment(env: VCheckEnvironment)")
            self.environment = VCheckEnvironment.DEV
        }
        if (self.environment == VCheckEnvironment.DEV) {
            print("VCheckSDK - warning: using DEV environment | see VCheckSDK.shared.environment(env: VCheckEnvironment)")
        }
        if (self.verificationToken == nil) {
            throw VCheckError.initError("VCheckSDK - error: proper verification token must be provided | see VCheckSDK.shared.verificationToken(token: String)")
        }
        if (self.verificationType == nil) {
            throw VCheckError.initError("VCheckSDK - error: proper verification type must be provided | see VCheckSDK.shared.verificationType(type: VerificationSchemeType)")
        }
        if (self.partnerEndCallback == nil) {
            throw VCheckError.initError("VCheckSDK - error: partner application's callback function (invoked on SDK flow finish) must be provided | see VCheckSDK.shared.partnerEndCallback(callback: (() -> Void))")
        }
        if (self.onVerificationExpired == nil) {
            throw VCheckError.initError("VCheckSDK - error: partner application's onVerificationExpired function " +
                 "(invoked on SDK's current verification expiration case) must be provided by partner app | " +
                 "see VCheckSDK.shared.onVerificationExpired(callback: (() -> Void))")
        }
        if (self.sdkLanguageCode == nil) {
            throw VCheckError.initError("VCheckSDK - warning: sdk language code is not set; using English (en) locale as default. " +
                            "| see VCheckSDK.shared.sdkLanguageCode(langCode: String)")
        }
        if (self.sdkLanguageCode != nil && !VCheckSDKConstants
                .vcheckSDKAvailableLanguagesList.contains((self.sdkLanguageCode?.lowercased())!)) {
            throw VCheckError.initError("VCheckSDK - error: SDK is not localized with [$sdkLanguageCode] locale yet. " +
                    "You may set one of the next locales: ${VCheckSDKConstantsProvider.vcheckSDKAvailableLanguagesList}, " +
                    "or check out for the recent version of the SDK library")
        }
        if (self.designConfig == nil) {
            print("VCheckSDK - warning: No instance of VCheckDesignConfig was passed while " +
                  "initializing SDK | setting VCheck default theme...")
            self.designConfig = VCheckDesignConfig.fromJsonStr(rawJsonStr: VCheckSDKConstants.vcheckDefaultThemeConfig)
        }
    }
    
    public func partnerEndCallback(callback: (() -> Void)?) -> VCheckSDK {
        self.partnerEndCallback = callback
        return self
    }
    
    public func onVerificationExpired(callback: (() -> Void)?) -> VCheckSDK {
        self.onVerificationExpired = callback
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
    
    /// Internal caching functions

    internal func getEnvironment() -> VCheckEnvironment {
        return self.environment ?? VCheckEnvironment.DEV
    }
    
    internal func getSelectedProvider() -> Provider {
        if (selectedProvider == nil) {
            print("VCheckSDK - error: provider is not set!")
        }
        return selectedProvider!
    }

    internal func setSelectedProvider(provider: Provider) {
        self.selectedProvider = provider
    }

    internal func setAllAvailableProviders(providers: [Provider]) {
        self.allAvailableProviders = providers
    }

    internal func getAllAvailableProviders() -> [Provider] {
        if (allAvailableProviders == nil) {
            print("VCheckSDK - error: no providers were cached properly!")
        }
        return allAvailableProviders!
    }

    internal func setProviderLogicCase(providerLC: ProviderLogicCase) {
        self.providerLogicCase = providerLC
    }

    internal func getProviderLogicCase() -> ProviderLogicCase {
        if (providerLogicCase == nil) {
            print("VCheckSDK - error: no provider logic case was set!")
        }
        return providerLogicCase!
    }

    internal func getOptSelectedCountryCode() -> String? {
        return optSelectedCountryCode
    }

    internal func setOptSelectedCountryCode(code: String) {
        self.optSelectedCountryCode = code
    }
    
    internal func setIsVerificationExpired(isExpired: Bool) {
        self.isVerifExpired = isExpired
    }

    internal func isVerificationExpired() -> Bool {
        return self.isVerifExpired
    }
    
    ///Color public customization methods:
    
    public func designConfig(config: VCheckDesignConfig) -> VCheckSDK {
        self.designConfig = config
        return self
    }

    //TODO: refactor to remove f-n usage
//    func resetCustomColors() {
//        self.iconsColorHex = nil
//        //self.colorButtonsText = nil
//        self.buttonsColorHex = nil
//        self.backgroundPrimaryColorHex = nil
//        self.backgroundSecondaryColorHex = nil
//        self.backgroundTertiaryColorHex = nil
//        self.primaryTextColorHex = nil
//        self.secondaryTextColorHex = nil
//        self.borderColorHex = nil
//    }
    
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
}
