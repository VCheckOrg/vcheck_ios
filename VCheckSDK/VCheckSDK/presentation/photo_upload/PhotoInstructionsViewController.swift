//
//  PhotoInstructionsViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 06.05.2022.
//

import Foundation
import UIKit

class PhotoInstructionsViewController : UIViewController {
    
    @IBOutlet weak var proceedBtn: UIButton!
    
    @IBAction func backToDocType(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        
        self.proceedBtn.setTitle("proceed".localized, for: .normal)
    }
}
