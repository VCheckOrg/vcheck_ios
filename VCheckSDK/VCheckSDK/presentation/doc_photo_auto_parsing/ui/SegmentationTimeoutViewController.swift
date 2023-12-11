//
//  SegmentationTimeoutViewController.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 10.08.2022.
//

import Foundation
import UIKit

class SegmentationTimeoutViewController: UIViewController {
    
    @IBOutlet weak var tvTimeoutTitle: PrimaryTextView!
    
    @IBOutlet weak var tvTimeoutDescr: SecondaryTextView!
    
    @IBOutlet weak var pseudoBtnMakePhotoByHand: VCheckSDKRoundedView!
    
    @IBOutlet weak var makePhotoByHandText: PrimaryTextView!
    
    @IBOutlet weak var btnRetry: UIButton!
    
    var onRepeatBlock : ((Bool) -> Void)?
    
    var isInvalidDocError: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (isInvalidDocError == false) {
            self.tvTimeoutTitle.isHidden = false
            self.tvTimeoutTitle.text = "no_time_seg_title".localized
            self.tvTimeoutDescr.text = "no_time_seg_descr".localized
        } else {
            self.tvTimeoutTitle.isHidden = true
            self.tvTimeoutDescr.text = "fatal_error_seg_descr".localized
        }
        
        self.btnRetry.setTitle("retry".localized, for: .normal)
        self.makePhotoByHandText.text = "make_photo_by_hand".localized
        
        if (isInvalidDocError == false) {
            btnRetry.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector (self.declineSessionAndCloseVC(_:))))
        } else {
            btnRetry.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector (self.reopenSegVC(_:))))
        }
        
        pseudoBtnMakePhotoByHand.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector (self.makePhotoByHand(_:))))
    }
    
    @objc func declineSessionAndCloseVC(_ sender: UITapGestureRecognizer) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200) ) {
            self.navigationController?.popViewController(animated: true)
            self.onRepeatBlock!(true)
        }
    }
    
    @objc func reopenSegVC(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "SegErrToRecreateSeg", sender: nil)
    }
    
    @objc func makePhotoByHand(_ sender: UITapGestureRecognizer) {
        VCheckSDKLocalDatasource.shared.setManualPhotoUpload()
        self.performSegue(withIdentifier: "SegErrToManualUpload", sender: nil)
    }
}
