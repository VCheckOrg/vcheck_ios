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
        self.navigationController?.dismiss(animated: false, completion: nil)
        self.videoProcessingViewController?.uploadVideo()
    }
    
    @IBAction func contactSupport(_ sender: UIButton) {
        let appURL = URL(string: "mailto:info@vycheck.com")!
        UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.closeBtn.setTitle("retry".localized, for: .normal)
    }
}
