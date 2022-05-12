//
//  NoTimeViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 08.05.2022.
//

import Foundation
import UIKit

class NoTimeViewController: UIViewController {
    
    var onRepeatBlock : ((Bool) -> Void)?
    
    @IBAction func ntBackAction(_ sender: UIButton) {
        //self.dismiss(animated: true)
        //TODO: add short delay before dismissing to perevent video recording bug
        navigationController?.popViewController(animated: true)
        onRepeatBlock!(true)
    }
}
