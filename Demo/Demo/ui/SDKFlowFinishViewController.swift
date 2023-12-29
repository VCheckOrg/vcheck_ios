//
//  SDKFlowFinishViewController.swift
//  Demo
//
//  Created by Kirill Kaun on 28.12.2023.
//

import Foundation
import UIKit

class SDKFlowFinishViewController: UIViewController {
    
    
    @IBOutlet weak var statusImageView: UIImageView!
    
    @IBOutlet weak var statusTitle: UILabel!
    
    @IBOutlet weak var statusSubtitle: UILabel!
    
    @IBOutlet weak var restartPseudoBtn: AppRoundedView!
    
    @IBOutlet weak var becomePartnerButton: UIButton!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var retryLabel: UILabel!
    
    @IBAction func closeSDKFlow(_ sender: Any) {
        if (timer != nil) {
            timer?.invalidate()
        }
        self.dismiss(animated: true)
    }
    
    @IBOutlet weak var closeSDKFlowTxt: UILabel!
    
    private var timer: Timer? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadingIndicator.isHidden = false
        
        self.retryLabel.text = "repeat_demo".localized
        self.becomePartnerButton.setTitle("become_a_partner".localized, for: .normal)
        
        self.becomePartnerButton.isHidden = true
        self.restartPseudoBtn.isHidden = true
        
        self.statusTitle.text = "verification_in_process_title".localized
        self.statusSubtitle.text = "verification_in_process_subtitle".localized
        
        closeSDKFlowTxt.text = "pop_sdk_title".localized

        self.timer = Timer.scheduledTimer(timeInterval: 2, target: self,
                                          selector: #selector(checkFinalVerificationStatus), userInfo: nil, repeats: true)
    }
    
    
    @objc func checkFinalVerificationStatus() {
        RemoteDatasource.shared.checkFinalVerificationStatus(completion: { (response, error) in
            if let error = error {
                print("Error while checking verification status: \(error)")
                return
            }
            if let response = response {
                print("FINAL ST RESPONSE: \(response)")
                if (response.data != nil) {
                    let result = VerificationCheckResult.init(fromData: response.data!)
                    self.processVerificationStatusResult(result: result)
                } else {
                    print("VCheckSDK - error: no data response received from checkFinalVerificationStatus request!")
                }
            }
        })
    }
        
    
    private func processVerificationStatusResult(result: VerificationCheckResult?) {
        if let r: VerificationCheckResult = result {
            if (r.isFinalizedAndSuccessful()) {
                self.loadingIndicator.isHidden = true
                
                self.statusImageView.image = UIImage(named: "imgVerifSuccess")
                
                self.statusTitle.text = "verification_success_title".localized
                self.statusSubtitle.text = "verification_success_descr".localized
                
                self.becomePartnerButton.isHidden = false
                self.restartPseudoBtn.isHidden = false
                
                let restartTapGesture = NavGestureRecognizer.init(target: self, action: #selector(self.onRestartClick(_:)))
                restartTapGesture.numberOfTapsRequired = 1
                restartTapGesture.timer = timer
                self.restartPseudoBtn.addGestureRecognizer(restartTapGesture)
                
                let bpTapGesture = NavGestureRecognizer.init(target: self, action: #selector(self.onBecomePartnerClick(_:)))
                bpTapGesture.numberOfTapsRequired = 1
                bpTapGesture.timer = timer
                self.becomePartnerButton.addGestureRecognizer(bpTapGesture)
            }
            if (r.isFinalizedAndFailed()) {
                self.loadingIndicator.isHidden = true
                
                self.statusImageView.image = UIImage(named: "imgVerifFailure")
                
                self.statusTitle.text = "verification_failed_title".localized
                self.statusSubtitle.text = "verification_failed_descr".localized
                
                self.becomePartnerButton.isHidden = true
                self.restartPseudoBtn.isHidden = false
                
                let restartTapGesture = NavGestureRecognizer.init(target: self, action: #selector(self.onRestartClick(_:)))
                restartTapGesture.numberOfTapsRequired = 1
                restartTapGesture.timer = timer
                self.restartPseudoBtn.addGestureRecognizer(restartTapGesture)
            }
        }
    }
    
    @objc func onRestartClick(_ sender: NavGestureRecognizer) {
        if (sender.timer != nil) {
            sender.timer?.invalidate()
        }
        self.dismiss(animated: true)
    }
    
    @objc func onBecomePartnerClick(_ sender: NavGestureRecognizer) {
        if (sender.timer != nil) {
            sender.timer?.invalidate()
        }
        performSegue(withIdentifier: "VerifStatusToBecomePartner", sender: nil)
    }
}
