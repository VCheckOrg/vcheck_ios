//
//  CheckDocPhotoViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 04.05.2022.
//

import Foundation
import UIKit

class CheckDocPhotoViewController : UIViewController {
    
    private let viewModel = CheckDocPhotoViewModel()
    
    var firstPhoto: UIImage? = nil
    var secondPhoto: UIImage? = nil
    
    @IBOutlet weak var secondPhotoCard: RoundedView!
    
    @IBOutlet weak var imgViewPhotoFirst: UIImageView!
    @IBOutlet weak var imgViewPhotoSecond: UIImageView!
    
    @IBOutlet weak var remakeDocPhotosBtn: RoundedView!
    
    @IBOutlet weak var confirmUploadPhotosBtn: UIButton!
    
    @IBOutlet weak var zoomFirstPhotoBtn: UIImageView!
    @IBOutlet weak var zoomSecondPhotoBtn: UIImageView!
    
    @IBOutlet weak var confirmBtnVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var remakeBtnVerticalConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        
        imgViewPhotoFirst.image = firstPhoto
        
        if (secondPhoto != nil) {
            secondPhotoCard.isHidden = false
            imgViewPhotoSecond.image = secondPhoto
        } else {
            secondPhotoCard.isHidden = true
        }
    }
}
