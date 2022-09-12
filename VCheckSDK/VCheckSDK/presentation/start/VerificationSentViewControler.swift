//
//  VerificationSentViewControler.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 12.09.2022.
//

import Foundation
import UIKit

class VerificationSentViewControler: UIViewController {
    
    @IBOutlet weak var tvTitle: PrimaryTextView!
    
    @IBOutlet weak var tvSubtitle: SecondaryTextView!
    
    @IBOutlet weak var btnBack: UIButton!
    
    @IBAction func actionBackToPartner(_ sender: Any) {
        VCheckSDK.shared.finish(executePartnerCallback: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tvTitle.text = "verification_in_process_title".localized
        tvSubtitle.text = "verification_in_process_subtitle".localized
        
        btnBack.setTitle("got_it".localized, for: .normal)
    }
    
}
