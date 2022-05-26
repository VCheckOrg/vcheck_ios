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
    
    //TODO: test
    @IBAction func actionRetry(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: false, completion: nil)
        self.videoProcessingViewController?.uploadVideo()
    }
    
    @IBAction func contactSupport(_ sender: UIButton) {
        let appURL = URL(string: "mailto:info@vycheck.com")!
        UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
    }
}
