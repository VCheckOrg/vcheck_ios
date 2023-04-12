//
//  ProviderViewCell.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 12.04.2023.
//

import Foundation

import Foundation
import UIKit

class ProviderViewCell : UITableViewCell {
    
    @IBOutlet weak var providerTitle: PrimaryTextView!
    
    @IBOutlet weak var providerSubTitle: SecondaryTextView!
    
    func setProviderTitle(name: String) {
        providerTitle.text = name
    }
    
    func setProviderSubitle(name: String) {
        providerSubTitle.text = name
    }
}
