//
//  MultipleFacesDetectedViewContoller.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 08.05.2022.
//

import Foundation
import UIKit

class MultipleFacesDetectedViewController : UIViewController {
    
    var onRepeatBlock : ((Bool) -> Void)?
    
    @IBAction func nfRepeatAction(_ sender: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700) ) {
            self.navigationController?.popViewController(animated: true)
            self.onRepeatBlock!(true)
        }
    }
}
