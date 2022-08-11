//
//  ZoomedDocPhotoViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 04.05.2022.
//

import Foundation
import UIKit

class ZoomedDocPhotoViewController : UIViewController {
    
    var photoToZoom: UIImage? = nil
    
    @IBOutlet weak var zoomedImgView: UIImageView!
    
    @IBAction func backToCheckAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        
        if (photoToZoom != nil) {
            zoomedImgView.image = photoToZoom
        }
    }
}
