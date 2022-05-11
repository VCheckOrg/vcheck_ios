//
//  HeaderViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 11.05.2022.
//

import Foundation
import UIKit

class HeaderViewContoller: UIViewController {
    
    
    @IBOutlet weak var showButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let usersItem = UIAction(title: "Users", image: UIImage(systemName: "person.fill")) { (action) in
                print("Users action was tapped")
        }

        let addUserItem = UIAction(title: "Add User", image: UIImage(systemName: "person.badge.plus")) { (action) in
            print("Add User action was tapped")
        }

        let removeUserItem = UIAction(title: "Remove User", image: UIImage(systemName: "person.fill.xmark.rtl")) { (action) in
             print("Remove User action was tapped")
        }

        let menu = UIMenu(title: "My Menu", options: .displayInline, children: [usersItem , addUserItem , removeUserItem])
        
        showButton.menu = menu
        showButton.showsMenuAsPrimaryAction = true
    }
}

