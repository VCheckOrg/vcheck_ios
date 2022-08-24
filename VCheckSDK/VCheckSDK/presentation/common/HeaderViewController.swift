//
//  HeaderViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 11.05.2022.
//

import Foundation
import UIKit


class HeaderViewContoller: UIViewController {
    
    
    @IBAction func actionCloseSDKFlow(_ sender: Any) {
        if (VCheckSDK.shared.showCloseSDKButton) {
            VCheckSDK.shared.finish(executePartnerCallback: false)
        }
    }
    
    @IBOutlet weak var closeSDKFlowTitle: SecondaryTextView!
    
    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var icBackArrow: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Bundle.setLanguage(VCheckSDK.shared.getSDKLangCode())
        
        if (VCheckSDK.shared.showCloseSDKButton == true) {
            closeSDKFlowTitle.isHidden = false
            icBackArrow.isHidden = false
        } else {
            closeSDKFlowTitle.isHidden = true
            icBackArrow.isHidden = true
        }
        logo.isHidden = !VCheckSDK.shared.showPartnerLogo
        
        self.changeColorsToCustomIfPresent()
        
        closeSDKFlowTitle.text = "pop_sdk_title".localized
     }
     
     private func changeColorsToCustomIfPresent() {
         
         if let btnsHex = VCheckSDK.shared.buttonsColorHex {
             UIButton.appearance().tintColor = btnsHex.hexToUIColor()
         }
         if let backgroundHex = VCheckSDK.shared.backgroundPrimaryColorHex {
             BackgroundView.appearance().backgroundColor = backgroundHex.hexToUIColor()
         }
         if let backgroundSecondaryHex = VCheckSDK.shared.backgroundSecondaryColorHex {
             VCheckSDKRoundedView.appearance().backgroundColor = backgroundSecondaryHex.hexToUIColor()
             DocInfoViewCell.appearance().backgroundColor = backgroundSecondaryHex.hexToUIColor()
             UIView.appearance(whenContainedInInstancesOf: [DocInfoViewCell.self]).backgroundColor = UIColor.clear
//             UITableView.appearance().backgroundColor = UIColor.clear
//             UITableView.appearance().separatorColor = UIColor.clear
         }
         if let backgroundTertiaryHex = VCheckSDK.shared.backgroundTertiaryColorHex {
             SmallRoundedView.appearance().backgroundColor = backgroundTertiaryHex.hexToUIColor()
             SmallRoundedView.appearance(whenContainedInInstancesOf: [DocInfoViewCell.self]).backgroundColor = backgroundTertiaryHex.hexToUIColor()
             UITextField.appearance().backgroundColor = backgroundTertiaryHex.hexToUIColor()
             FlagView.appearance().backgroundColor = backgroundTertiaryHex.hexToUIColor()
             CustomizableTableView.appearance().backgroundColor = backgroundTertiaryHex.hexToUIColor()
             CustomBackgroundTextView.appearance().backgroundColor = backgroundTertiaryHex.hexToUIColor()
             AllowedCountryViewCell.appearance().backgroundColor = backgroundTertiaryHex.hexToUIColor()
             BlockedCountryViewCell.appearance().backgroundColor = backgroundTertiaryHex.hexToUIColor()
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
             CustomBackgroundTextView.appearance().textColor = primaryTextHex.hexToUIColor()
         }
         if let secondaryTextHex = VCheckSDK.shared.secondaryTextColorHex {
             SecondaryTextView.appearance().textColor = secondaryTextHex.hexToUIColor()
             NonCustomizableIconView.appearance().tintColor = secondaryTextHex.hexToUIColor()
         }
         if let iconsColorHex = VCheckSDK.shared.iconsColorHex {
             CustomizableIconView.appearance().tintColor = iconsColorHex.hexToUIColor()
         }
     }
}
