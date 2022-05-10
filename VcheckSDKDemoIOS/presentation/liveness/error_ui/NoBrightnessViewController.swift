//
//  NoBrightnessViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 08.05.2022.
//

import Foundation
import UIKit

class NoBrightnessViewController : UIViewController {
    
    var onRepeatBlock : ((Bool) -> Void)?
    
    @IBAction func nvRepeatAction(_ sender: UIButton) {
        self.dismiss(animated: true)
        onRepeatBlock!(true)
    }
}
