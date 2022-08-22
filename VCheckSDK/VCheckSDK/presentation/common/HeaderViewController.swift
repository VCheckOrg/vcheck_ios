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
        
        self.changeColorsToCustomIfPresent()
     }
     
     func changeColorsToCustomIfPresent() {
         if let btnsHex = VCheckSDK.shared.buttonsColorHex {
             UIButton.appearance().tintColor = btnsHex.hexToUIColor()
         }
         if let backgroundSecondaryHex = VCheckSDK.shared.backgroundSecondaryColorHex {
             VCheckSDKRoundedView.appearance().backgroundColor = backgroundSecondaryHex.hexToUIColor()
             DocInfoViewCell.appearance().backgroundColor = backgroundSecondaryHex.hexToUIColor()
             UIView.appearance(whenContainedInInstancesOf: [DocInfoViewCell.self]).backgroundColor = UIColor.clear

             UITableView.appearance().backgroundColor = UIColor.clear
             UITableView.appearance().separatorColor = UIColor.clear
         }
         if let backgroundHex = VCheckSDK.shared.backgroundPrimaryColorHex {
             BackgroundView.appearance().backgroundColor = backgroundHex.hexToUIColor()
         }
         if let backgroundTertiaryHex = VCheckSDK.shared.backgroundTertiaryColorHex {
             SmallRoundedView.appearance().backgroundColor = backgroundTertiaryHex.hexToUIColor()
             SmallRoundedView.appearance(whenContainedInInstancesOf: [DocInfoViewCell.self]).backgroundColor = backgroundTertiaryHex.hexToUIColor()
             UITextField.appearance().backgroundColor = backgroundTertiaryHex.hexToUIColor()
             FlagView.appearance().backgroundColor = backgroundTertiaryHex.hexToUIColor()
         }
         if let borderColorHex = VCheckSDK.shared.borderColorHex {
             SmallRoundedView.appearance().borderColor = borderColorHex.hexToUIColor()
             VCheckSDKRoundedView.appearance().borderColor = borderColorHex.hexToUIColor()
         }
         if let primaryTextHex = VCheckSDK.shared.primaryTextColorHex {
             PrimaryTextView.appearance().textColor = primaryTextHex.hexToUIColor()
             UITextField.appearance().textColor = primaryTextHex.hexToUIColor()
             UIImageView.appearance().tintColor = primaryTextHex.hexToUIColor()
             UITextView.appearance(whenContainedInInstancesOf: [DocInfoViewCell.self]).textColor = primaryTextHex.hexToUIColor()
         }
         if let secondaryTextHex = VCheckSDK.shared.secondaryTextColorHex {
             SecondaryTextView.appearance().textColor = secondaryTextHex.hexToUIColor()
         }
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


