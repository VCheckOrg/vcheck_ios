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
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700) ) {
            self.navigationController?.popViewController(animated: true)
            self.onRepeatBlock!(true)
        }
    }
}
