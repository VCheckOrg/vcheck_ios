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
    
    @IBOutlet weak var retryBtn: UIButton!
    
    @IBAction func ntBackAction(_ sender: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700) ) {
            self.navigationController?.popViewController(animated: true)
            self.onRepeatBlock!(true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.retryBtn.setTitle("retry".localized, for: .normal)
    }
}
