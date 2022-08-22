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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tvTimeoutTitle.text = "no_time_seg_title".localized
        tvTimeoutDescr.text = "no_time_seg_descr".localized
        
        btnRetry.setTitle("retry".localized, for: .normal)
        makePhotoByHandText.text = "make_photo_by_hand".localized
        
        btnRetry.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector (self.declineSessionAndCloseVC(_:))))
    }
    
    @objc func declineSessionAndCloseVC(_ sender: UITapGestureRecognizer) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700) ) {
            self.navigationController?.popViewController(animated: true)
            self.onRepeatBlock!(true)
        }
    }
    
    //TODO: test
    @objc func makePhotoByHand(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "SegTimeoutToManualUpload", sender: nil)
    }
}
