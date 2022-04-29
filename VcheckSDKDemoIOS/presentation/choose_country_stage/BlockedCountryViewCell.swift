//
//  BlockedCountryViewCell.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 29.04.2022.
//

import Foundation
import UIKit

class BlockedCountryViewCell : UITableViewCell {
    
    
    @IBOutlet weak var tvCountryFlag: UITextView!
    
    @IBOutlet weak var tvCountryName: UITextView!
    
    func setCountryName(name: String) {
        tvCountryName.text = name
    }
    
    func setCountryFlag(flag: String) {
        tvCountryFlag.text = flag
    }
}
