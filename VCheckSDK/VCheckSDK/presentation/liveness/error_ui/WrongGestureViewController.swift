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
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700) ) {
            self.navigationController?.popViewController(animated: true)
            self.onRepeatBlock!(true)
        }
    }
    
    @IBOutlet weak var retryBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.retryBtn.setTitle("retry".localized, for: .normal)
    }
}
