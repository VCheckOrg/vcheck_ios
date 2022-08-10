//
//  SegmentationTimeoutViewController.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 10.08.2022.
//

import Foundation
import UIKit

class SegmentationTimeoutViewController: UIViewController {
    
    @IBOutlet weak var tvTimeoutTitle: UILabel!
    
    @IBOutlet weak var btnRetry: UIButton!
    
    var onRepeatBlock : ((Bool) -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tvTimeoutTitle.text = "no_time_seg_title".localized
        btnRetry.setTitle("retry".localized, for: .normal)
        
        btnRetry.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector (self.declineSessionAndCloseVC(_:))))
    }
    
    @objc func declineSessionAndCloseVC(_ sender: UITapGestureRecognizer) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700) ) {
            self.navigationController?.popViewController(animated: true)
            self.onRepeatBlock!(true)
        }
    }
}
