//
//  LivenessSuccessViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 10.05.2022.
//

import Foundation
import UIKit

class LivenessSuccessViewController: UIViewController {
    
    @IBAction func livenessSuccessAction(_ sender: UIButton) {
        //Close app for new test
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { exit(0) }
    }
}
