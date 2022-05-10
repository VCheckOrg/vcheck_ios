//
//  NoFaceDetectedViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 08.05.2022.
//

import Foundation
import UIKit

class NoFaceDetectedViewController : UIViewController {
    
    var onRepeatBlock : ((Bool) -> Void)?
    
    @IBAction func nfRetryAction(_ sender: Any) {
        self.dismiss(animated: true)
        onRepeatBlock!(true)
    }
}
