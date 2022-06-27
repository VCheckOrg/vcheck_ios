//
//  HeaderViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 11.05.2022.
//

import Foundation
import UIKit


class HeaderViewContoller: UIViewController {
    
    
    @IBOutlet weak var showButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let deviceLocale = Locale.current.languageCode!
        
        if (GlobalUtils.getVCheckCurrentLanguageCode() != deviceLocale && LocalDatasource.shared.isLocaleUserDefined() == false) {
            Bundle.setLanguage(deviceLocale)
        }
        
        print("BUNDLE CURR LANGUAGE: \(GlobalUtils.getVCheckCurrentLanguageCode())")
        
        refreshMenu()
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
        
        var children: [UIAction] = []
        
        switch(GlobalUtils.getVCheckCurrentLanguageCode()) {
            case "uk": children = [ukItem, enItem, ruItem]
            case "ru": children = [ruItem, ukItem, enItem]
            default: children = [enItem, ukItem, ruItem]
        }

        let menu = UIMenu(title: "Choose Language", options: .displayInline, children: children)
        
        showButton.menu = menu
        showButton.showsMenuAsPrimaryAction = true
    }
    
    func onLocaleChangeAttempt(locale: String) {
        let alert = UIAlertController(title: "Switch Language",
                                      message: "Verification flow will be restarted if you switch language. Are you sure?",
                                      preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
            
            (UIAlertAction) -> Void in
            
            LocalDatasource.shared.setLocaleIsUserDefined()
            
            print("------- SELECTED \(locale)")
            Bundle.setLanguage(locale)
            
            GlobalUtils.setVCheckCurrentLanguageCode(langCode: locale)
            print("BUNDLE CURR LANGUAGE: \(GlobalUtils.getVCheckCurrentLanguageCode())")
            
            let storyboard = UIStoryboard(name: "VCheckFlow", bundle: InternalConstants.bundle)
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
}


//! TODO: separate this logic to framework only
extension UIApplication {

  static var topWindow: UIWindow {
    if #available(iOS 15.0, *) {
      let scenes = UIApplication.shared.connectedScenes
      let windowScene = scenes.first as? UIWindowScene
      return windowScene!.windows.first!
    } else {
        return UIApplication.shared.windows.filter { $0.isKeyWindow }.first!
    }
  }
}


