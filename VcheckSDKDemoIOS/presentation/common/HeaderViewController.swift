//
//  HeaderViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 11.05.2022.
//

import Foundation
import UIKit
import Localize_Swift


class HeaderViewContoller: UIViewController {
    
    
    @IBOutlet weak var showButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let deviceLocale = Locale.current.languageCode!
        
        if (deviceLocale != Localize.currentLanguage() && LocalDatasource.shared.isLocaleUserDefined() == false) {
            Localize.setCurrentLanguage(deviceLocale)
        }
        
        print("LOCALIZE CURR LANGUAGE: \(Localize.currentLanguage())")
        
        let ukItem = UIAction(title: "Українська", image: nil) { (action) in
            self.onLocaleSelected(locale: "uk")
        }
        let enItem = UIAction(title: "English", image: nil) { (action) in
            self.onLocaleSelected(locale: "en")
        }
        let ruItem = UIAction(title: "Русский", image: nil) { (action) in
            self.onLocaleSelected(locale: "ru")
        }
        
        var children: [UIAction] = []
        
        switch(Localize.currentLanguage()) {
            case "uk": children = [ukItem, enItem, ruItem]
            case "ru": children = [ruItem, ukItem, enItem]
            default: children = [enItem, ukItem, ruItem]
        }

        let menu = UIMenu(title: "Choose Language", options: .displayInline, children: children)
        
        showButton.menu = menu
        showButton.showsMenuAsPrimaryAction = true
    }
    
    func onLocaleSelected(locale: String) {
        LocalDatasource.shared.setLocaleIsUserDefined()
        
        print("------- SELECTED \(locale)")
        Localize.setCurrentLanguage(locale)
        print("LOCALIZE CURR LANGUAGE: \(Localize.currentLanguage())")
        
//        UserDefaults.standard.set(Localize.currentLanguage(), forKey: "AppleLanguages")
//        UserDefaults.standard.synchronize()
        
        Bundle.setLanguage(locale)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        UIApplication.topWindow.rootViewController = storyboard.instantiateInitialViewController()
    }
}

