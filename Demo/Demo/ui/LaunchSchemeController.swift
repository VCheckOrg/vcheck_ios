//
//  ChooseSchemeController.swift
//  Demo
//
//  Created by Kirill Kaun on 28.12.2023.
//

import Foundation

import UIKit
import VCheckSDK

class LaunchSchemeController: UIViewController, UIColorPickerViewControllerDelegate {
    
    @IBOutlet weak var chooseColorTitle: UILabel!
    
    @IBOutlet weak var showButton: UIButton!
    
    @IBOutlet weak var fullFlowBtn: UIButton!
    @IBOutlet weak var docCheckOnlyBtn: UIButton!
    @IBOutlet weak var livenessOnlyBtn: UIButton!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var contentScrollView: UIScrollView!
    
    @IBOutlet weak var pasteConficButton: UIButton!
        
    @IBAction func startFullSDKFlow(_ sender: Any) {
        self.createVerification(verifType: VerificationSchemeType.FULL_CHECK)
    }
    @IBAction func startDocCheckOnlyFlow(_ sender: Any) {
        self.createVerification(verifType: VerificationSchemeType.DOCUMENT_UPLOAD_ONLY)
    }
    @IBAction func startLivenessOnlyFlow(_ sender: Any) {
        self.createVerification(verifType: VerificationSchemeType.LIVENESS_CHALLENGE_ONLY)
    }
    
    private var langCode: String = "uk"
    
    private var designConfig: VCheckDesignConfig = VCheckDesignConfig.getDefaultThemeConfig()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///Overriding entire app and SDK theme to light (essential ATM)
        if #available(iOS 13.0, *) {
            getOwnSceneDelegate()?.window!.overrideUserInterfaceStyle = .light
        }
        
        if (LocalDatasource.shared.isLocaleUserDefined() == true) {
            self.langCode = LocalDatasource.shared.getCurrentSDKLangauge()
            Bundle.setLanguage(self.langCode)
        } else {
            self.langCode = Locale.current.languageCode!
        }
        
        self.loadingIndicator.isHidden = true
        
        setLocalizedTexts()
        
        setupPasteConfigButton()
        
        refreshMenu()
    }
    
    func setupPasteConfigButton() {
        self.pasteConficButton.setTitle("upload_design_config_file".localized, for: .normal)
        self.pasteConficButton.addTarget(self, action: #selector(didPasteConfigButtonClick), for: .touchUpInside)
    }
    
    @objc func didPasteConfigButtonClick(_ sender: UIButton) {
        if let possibleJsonData = UIPasteboard.general.string {
                
            if (!possibleJsonData.isEmpty) {
                if let value = try? JSONDecoder()
                    .decode(VCheckDesignConfig.self, from: possibleJsonData.data(using: .utf8)!) {
                    designConfig = value
                    showToast(controller: self, message: "Data successfuly pasted!", seconds: 2)
                } else {
                    showToast(controller: self, message: "Non-valid JSON was passed while initializing "
                              + "VCheckDesignConfig instance. Persisting VCheck default theme", seconds: 2)
                    designConfig = VCheckDesignConfig.getDefaultThemeConfig()
                }
            } else {
                showToast(controller: self, message: "Clipboard has no text!", seconds: 2)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        refreshMenu()
    }
    
    func createVerification(verifType: VerificationSchemeType) {
        
        self.loadingIndicator.isHidden = false
        self.contentScrollView.isHidden = true
        
        RemoteDatasource.shared.requestServerTimestamp(completion: { (timestamp, error) in
            if let ts = timestamp {
                RemoteDatasource.shared.createVerificationRequest(timestamp: ts,
                                                           locale: self.langCode,
                                                           scheme: verifType.description.lowercased(),
                                                           completion: { (data, error) in
                    if let error = error {
                        self.showToast(message: error, seconds: 3.0)
                        self.loadingIndicator.isHidden = true
                        self.contentScrollView.isHidden = false
                        return
                    }

                    LocalDatasource.shared.setVerificationId(id: data!.id!)
                    self.startSDK(verifType: verifType, token: data!.token!)
                })
            } else {
                self.showToast(message: "Error: server timestamp not set", seconds: 3.0)
                self.loadingIndicator.isHidden = true
                self.contentScrollView.isHidden = false
                return
            }
        })
    }
    
    ///An example on how to start SDK
    func startSDK(verifType: VerificationSchemeType, token: String) {
                                
        VCheckSDK.shared
            .verificationToken(token: token)
            .verificationType(type: verifType)
            .languageCode(langCode: self.langCode)
            .designConfig(config: self.designConfig)
            .environment(env: VCheckEnvironment.DEV)
            .showPartnerLogo(show: false)
            .showCloseSDKButton(show: true)
            .partnerEndCallback(callback: {
                self.onSDKFlowFinished()
            })
            .onVerificationExpired(callback: {
                self.onVerificationExpired()
            })
            .start(partnerAppRW: (getOwnSceneDelegate()?.window!)!,
                    partnerAppVC: self,
                    replaceRootVC: true)
        
        self.loadingIndicator.isHidden = true
        self.contentScrollView.isHidden = false
    }
    
    func setLocalizedTexts() {
        self.fullFlowBtn.setTitle("full_verification".localized, for: .normal)
        self.livenessOnlyBtn.setTitle("verification_of_liveness".localized, for: .normal)
        self.docCheckOnlyBtn.setTitle("verification_of_documents".localized, for: .normal)
        self.chooseColorTitle.text = "upload_design_config_descr".localized
    }
    
    func getOwnSceneDelegate() -> SceneDelegate? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene!.delegate as? SceneDelegate ?? nil
    }
    
    ///An example of the partner's app function of handling an SDK flow end
    func onSDKFlowFinished() {
        let sceneDelegate = getOwnSceneDelegate()!
        sceneDelegate.window!.rootViewController = self
        sceneDelegate.window!.makeKeyAndVisible()
        self.performSegue(withIdentifier: "StartToFinalLivenessCheck", sender: nil)
    }
    
    func onVerificationExpired() {
        DispatchQueue.main.async {
            self.showToast(controller: self, message: "Verification session expired. Please, try again", seconds: 3)
        }
    }
    
    @objc private func didTapSelectColor() {
        let colorPickerVC = UIColorPickerViewController()
        colorPickerVC.delegate = self
        present(colorPickerVC, animated: true)
    }
    
    func refreshMenu() {
        
        let ukItem = UIAction(title: "Українська", image: nil) { (action) in
            self.onLocaleChangeAttempt(locale: "uk")
        }
        let enItem = UIAction(title: "English", image: nil) { (action) in
            self.onLocaleChangeAttempt(locale: "en")
        }
        let ruItem = UIAction(title: "Русский", image: nil) { (action) in
            self.onLocaleChangeAttempt(locale: "ru")
        }
        let plItem = UIAction(title: "Polski", image: nil) { (action) in
            self.onLocaleChangeAttempt(locale: "pl")
        }
        
        var children: [UIAction] = []
                
        switch(self.langCode) {
            case "uk": children = [ukItem, enItem, plItem, ruItem]
            case "ru": children = [ruItem, ukItem, enItem, plItem]
            case "pl": children = [plItem, ruItem, ukItem, enItem]
            default: children = [enItem, ukItem, ruItem, plItem]
        }

        let menu = UIMenu(title: "Choose Language", options: .displayInline, children: children)
        
        switch(self.langCode) {
            case "uk": showButton.titleLabel?.text = "Українська"
            case "ru": showButton.titleLabel?.text = "Русский"
            case "pl": showButton.titleLabel?.text = "Polski"
            default: showButton.titleLabel?.text = "English"
        }
        
        showButton.menu = menu
        showButton.showsMenuAsPrimaryAction = true
    }
    
    func onLocaleChangeAttempt(locale: String) {
        let alert = UIAlertController(title: "Switch Language",
                                      message: "Are you sure?",
                                      preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
            
            (UIAlertAction) -> Void in
  
            LocalDatasource.shared.setLocaleIsUserDefined()
            LocalDatasource.shared.saveCurrentSDKLangauge(langCode: locale)
            
            Bundle.setLanguage(locale)
                        
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            UIApplication.topWindow.rootViewController = storyboard.instantiateInitialViewController()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) {
            (UIAlertAction) -> Void in
            
            self.refreshMenu()
        }
        alert.addAction(alertAction)
        alert.addAction(cancelAction)
        present(alert, animated: true) {
            () -> Void in
        }
    }
    
    func showToast(controller: UIViewController, message : String, seconds: Double) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.black
        alert.view.alpha = 0.6
        alert.view.layer.cornerRadius = 15

        controller.present(alert, animated: true)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
}
