//
//  VideoFailureViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 10.05.2022.
//

import Foundation
import UIKit

class VideoFailureViewController: UIViewController {
    
    var videoProcessingViewController: VideoProcessingViewController? = nil
    
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBAction func actionRetry(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.videoProcessingViewController?.uploadVideo()
    }
    
    
    @IBOutlet weak var contactSupportPseudoBtn: SmallRoundedView!
    
    @IBOutlet weak var contactSupportText: PrimaryTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.closeBtn.setTitle("retry".localized, for: .normal)
        
        self.contactSupportText.text = "contact_support".localized
        
        let contact = UITapGestureRecognizer(target: self, action: #selector(contactSupport(_:)))
        
        self.contactSupportPseudoBtn.addGestureRecognizer(contact)
    }
    
    @objc func contactSupport(_ sender: NavGestureRecognizer) {
        let appURL = URL(string: "mailto:info@vycheck.com")!
        UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
    }
    
}
