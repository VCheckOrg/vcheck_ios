//
//  CheckDocPhotoViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 04.05.2022.
//

import Foundation
import UIKit

class CheckDocPhotoViewController : UIViewController {
    
    var firstPhoto: UIImage? = nil
    var secondPhoto: UIImage? = nil
    
    @IBOutlet weak var secondPhotoCard: RoundedView!
    
    @IBOutlet weak var imgViewPhotoFirst: UIImageView!
    
    @IBOutlet weak var imgViewPhotoSecond: UIImageView!
    
    
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
