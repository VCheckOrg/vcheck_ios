//
//  HeaderViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 11.05.2022.
//

import Foundation
import UIKit


class HeaderViewContoller: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Bundle.setLanguage(VCheckSDK.shared.getSDKLangCode())

    }
        
}

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


