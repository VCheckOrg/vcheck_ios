//
//  AllowedCountryViewCell.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 29.04.2022.
//

import Foundation
import UIKit

class AllowedCountryViewCell : UITableViewCell {
    
    @IBOutlet weak var tvName: UITextView!
    
    @IBOutlet weak var tvFlag: UITextView!
    
    
    func setCountryName(name: String) {
        tvName.text = name
    }
    
    func setCountryFlag(flag: String) {
        tvFlag.text = flag
    }
}
