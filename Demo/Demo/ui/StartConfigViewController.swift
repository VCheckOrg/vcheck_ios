//
//  ViewController.swift
//  Demo
//
//  Created by Kirill Kaun on 28.12.2023.
//

import UIKit
import VCheckSDK

class StartConfigViewController: UIViewController {
    
    @IBOutlet weak var partnerIdTitle: UITextView!
    @IBOutlet weak var partnerSecretTitle: UITextView!
    @IBOutlet weak var designConfigTitle: UITextView!
    
    @IBOutlet weak var tfPartnerID: UITextField!
    @IBOutlet weak var tfPartnerSecret: UITextField!
    @IBOutlet weak var tfTVDesignConfig: UITextView!
    
    @IBOutlet weak var showButton: UIButton!
    
    @IBAction func pastePartnerId(_ sender: Any) {
        tfPartnerID.text = getClipboardData()
    }
    @IBAction func pastePartnerSecret(_ sender: Any) {
        tfPartnerSecret.text = getClipboardData()
    }
    @IBAction func pasteDesignConfig(_ sender: Any) {
        tfTVDesignConfig.text = getClipboardData()
    }
    
    @IBAction func clearPartnerId(_ sender: Any) {
        tfPartnerID.text = ""
    }
    @IBAction func clearPartnerSecret(_ sender: Any) {
        tfPartnerSecret.text = ""
    }
    @IBAction func clearDesignConfig(_ sender: Any) {
        tfTVDesignConfig.text = ""
    }
    
    @IBOutlet weak var btnChooseStage: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (LocalDatasource.shared.isLocaleUserDefined() == true) {
            LocalDatasource.shared.setLang(code: LocalDatasource.shared.getCurrentSDKLangauge())
            Bundle.setLanguage(LocalDatasource.shared.getLang())
        } else {
            LocalDatasource.shared.setLang(code: Locale.current.language.languageCode?.identifier ?? "uk")
        }
        
        ///Overriding entire app and SDK theme to light (essential ATM)
        if #available(iOS 13.0, *) {
            getOwnSceneDelegate()?.window!.overrideUserInterfaceStyle = .light
        }
        
        ///Hide keyboard on any outside tap
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
        
        refreshMenu()
        
        setLocalizedTexts()
        
        let bpTapGesture = NavGestureRecognizer.init(target: self, action: #selector(self.onValidatePartnerData(_:)))
        bpTapGesture.numberOfTapsRequired = 1
        self.btnChooseStage.addGestureRecognizer(bpTapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        refreshMenu()
    }
    
    private func setLocalizedTexts() {
        self.btnChooseStage.setTitle("choose_scheme".localized, for: .normal)
        
        self.partnerIdTitle.text = "partner_id".localized
        self.partnerSecretTitle.text = "partner_secret".localized
        self.designConfigTitle.text = "design_config_optional".localized
    }
    
    @objc func onValidatePartnerData(_ sender: NavGestureRecognizer) {
        
        if (validatePartnerId() && validateSecret() && validateDesignConfig()) {
            LocalDatasource.shared.setSecret(secret: tfPartnerSecret.text!)
            LocalDatasource.shared.setPartnerId(id: Int(tfPartnerID.text!)!)
            
            performSegue(withIdentifier: "StartToChooseScheme", sender: nil)
        }
    }
    
    private func getClipboardData() -> String {
        let pasteboard = UIPasteboard.general
        
        if let data = pasteboard.string, !data.isEmpty {
            showToast(message: "clipboard_pasted".localized, seconds: 1.0)
            return data
        } else {
            showToast(message: "err_clipboard_has_no_data".localized, seconds: 2.0)
            return ""
        }
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
                
        switch(LocalDatasource.shared.getLang()) {
            case "uk": children = [ukItem, enItem, plItem, ruItem]
            case "ru": children = [ruItem, ukItem, enItem, plItem]
            case "pl": children = [plItem, ruItem, ukItem, enItem]
            default: children = [enItem, ukItem, ruItem, plItem]
        }

        let menu = UIMenu(title: "Choose Language", options: .displayInline, children: children)
        
        switch(LocalDatasource.shared.getLang()) {
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
    
    func getOwnSceneDelegate() -> SceneDelegate? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene!.delegate as? SceneDelegate ?? nil
    }

    private func validatePartnerId() -> Bool {
        if Int(tfPartnerID.text ?? "") != nil {
            return true
        } else {
            showToast(message: "err_invalid_partner_id".localized, seconds: 2.0)
            return false
        }
    }

    private func validateSecret() -> Bool {
        if let data = tfPartnerSecret.text, !data.isEmpty {
            return true
        } else {
            showToast(message: "err_invalid_partner_secret".localized, seconds: 2.0)
            return false
        }
    }
    
    private func validateDesignConfig() -> Bool {
        if let data = tfTVDesignConfig.text, !data.isEmpty {
            if let value = try? JSONDecoder()
                .decode(VCheckDesignConfig.self, from: data.data(using: .utf8)!) {
                //designConfig = value
                VCheckSDK.shared.designConfig(config: value)
                return true
            } else {
                //TODO: may add stateful validation for TFs is needed
//                self.showToast(message: "Non-valid JSON was passed while initializing "
//                          + "VCheckDesignConfig instance. Persisting VCheck default theme", seconds: 2)
                VCheckSDK.shared.designConfig(config: VCheckDesignConfig.getDefaultThemeConfig())
                return true
            }
        } else {
            VCheckSDK.shared.designConfig(config: VCheckDesignConfig.getDefaultThemeConfig())
            return true
        }
    }
}

