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
         
         if let backgroundHex = VCheckSDK.shared.designConfig!.backgroundPrimaryColorHex {
             BackgroundView.appearance().backgroundColor = backgroundHex.hexToUIColor()
         }
         if let btnsHex = VCheckSDK.shared.designConfig!.primary {
             UIButton.appearance(whenContainedInInstancesOf: [BackgroundView.self]).tintColor = btnsHex.hexToUIColor()
         }
         if let backgroundSecondaryHex = VCheckSDK.shared.designConfig!.backgroundSecondaryColorHex {
             VCheckSDKRoundedView.appearance(whenContainedInInstancesOf: [BackgroundView.self]).backgroundColor = backgroundSecondaryHex.hexToUIColor()
             DocInfoViewCell.appearance(whenContainedInInstancesOf: [BackgroundView.self]).backgroundColor = backgroundSecondaryHex.hexToUIColor()
             UIView.appearance(whenContainedInInstancesOf: [DocInfoViewCell.self]).backgroundColor = UIColor.clear
             CustomizableTableView.appearance(whenContainedInInstancesOf: [VCheckSDKRoundedView.self]).backgroundColor = backgroundSecondaryHex.hexToUIColor()
         }
         if let backgroundTertiaryHex = VCheckSDK.shared.designConfig!.backgroundTertiaryColorHex {
             SmallRoundedView.appearance(whenContainedInInstancesOf: [BackgroundView.self]).backgroundColor = backgroundTertiaryHex.hexToUIColor()
             SmallRoundedView.appearance(whenContainedInInstancesOf: [DocInfoViewCell.self]).backgroundColor = backgroundTertiaryHex.hexToUIColor()
             UITextField.appearance(whenContainedInInstancesOf: [BackgroundView.self, CustomizableTableView.self]).backgroundColor = backgroundTertiaryHex.hexToUIColor()
             FlagView.appearance(whenContainedInInstancesOf: [BackgroundView.self]).backgroundColor = backgroundTertiaryHex.hexToUIColor()
             CustomizableTableView.appearance(whenContainedInInstancesOf: [BackgroundView.self]).backgroundColor = backgroundTertiaryHex.hexToUIColor()
             CustomBackgroundTextView.appearance(whenContainedInInstancesOf: [BackgroundView.self]).backgroundColor = backgroundTertiaryHex.hexToUIColor()
             AllowedCountryViewCell.appearance(whenContainedInInstancesOf: [BackgroundView.self]).backgroundColor = backgroundTertiaryHex.hexToUIColor()
             BlockedCountryViewCell.appearance(whenContainedInInstancesOf: [BackgroundView.self]).backgroundColor = backgroundTertiaryHex.hexToUIColor()
         }
         if let borderColorHex = VCheckSDK.shared.designConfig!.sectionBorderColorHex {
             SmallRoundedView.appearance(whenContainedInInstancesOf: [BackgroundView.self]).borderColor = borderColorHex.hexToUIColor()
             VCheckSDKRoundedView.appearance(whenContainedInInstancesOf: [BackgroundView.self]).borderColor = borderColorHex.hexToUIColor()
         }
         if let primaryTextHex = VCheckSDK.shared.designConfig!.primaryTextColorHex {
             PrimaryTextView.appearance(whenContainedInInstancesOf: [BackgroundView.self]).textColor = primaryTextHex.hexToUIColor()
             UITextField.appearance(whenContainedInInstancesOf: [BackgroundView.self, CustomizableTableView.self]).textColor = primaryTextHex.hexToUIColor()
             UIImageView.appearance(whenContainedInInstancesOf: [BackgroundView.self]).tintColor = primaryTextHex.hexToUIColor()
             UITextView.appearance(whenContainedInInstancesOf: [DocInfoViewCell.self]).textColor = primaryTextHex.hexToUIColor()
             CustomBackgroundTextView.appearance(whenContainedInInstancesOf: [BackgroundView.self]).textColor = primaryTextHex.hexToUIColor()
         }
         if let secondaryTextHex = VCheckSDK.shared.designConfig!.secondaryTextColorHex {
             SecondaryTextView.appearance(whenContainedInInstancesOf: [BackgroundView.self]).textColor = secondaryTextHex.hexToUIColor()
             NonCustomizableIconView.appearance(whenContainedInInstancesOf: [BackgroundView.self]).tintColor = secondaryTextHex.hexToUIColor()
         }
         if let iconsColorHex = VCheckSDK.shared.designConfig!.primary {
             CustomizableIconView.appearance(whenContainedInInstancesOf: [BackgroundView.self]).tintColor = iconsColorHex.hexToUIColor()
         }
     }
}
