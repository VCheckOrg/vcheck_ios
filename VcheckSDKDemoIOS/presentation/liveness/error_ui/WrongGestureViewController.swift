//
//  WrongGestureViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 08.05.2022.
//

import Foundation
import UIKit

class WrongGestureViewController : UIViewController {
    
    var onRepeatBlock : ((Bool) -> Void)?
    
    @IBAction func wgRepeatAction(_ sender: UIButton) {
        //self.dismiss(animated: true)
        navigationController?.popViewController(animated: true)
        onRepeatBlock!(true)
    }
}
