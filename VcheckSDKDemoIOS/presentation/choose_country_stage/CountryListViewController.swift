//
//  CountryListViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 25.04.2022.
//

import Foundation
import UIKit

class CountryListViewController : UIViewController {
    
    @IBOutlet var countryListTable: UITableView!
    
    var countries: [CountryTO] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countryListTable.delegate = self
        countryListTable.dataSource = self
    }
}

extension CountryListViewController: UITableViewDelegate {
    func tableView(_ countryListTable: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(countries[indexPath.row])
        //TODO: make reverse navigation back
    }
}

extension CountryListViewController: UITableViewDataSource {
    func tableView(_ countryListTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }

    func tableView(_ countryListTable: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell.init()
        if (countries[indexPath.row]).isBlocked {
            cell = countryListTable.dequeueReusableCell(
                withIdentifier: "blockedCountryCell", for: indexPath) as! BlockedCountryViewCell
        } else {
            cell = countryListTable.dequeueReusableCell(
                withIdentifier: "allowedCountryCell", for: indexPath) as! AllowedCountryViewCell
        }
        
        if (cell is AllowedCountryViewCell) {
            (cell as! AllowedCountryViewCell).setCountryName(name: countries[indexPath.row].name)
            (cell as! AllowedCountryViewCell).setCountryFlag(flag: countries[indexPath.row].flag)
        }
        else {
            (cell as! BlockedCountryViewCell).setCountryName(name: countries[indexPath.row].name)
            (cell as! BlockedCountryViewCell).setCountryFlag(flag: countries[indexPath.row].flag)
        }
        
        return cell
    }
    
    
    //TODO: add proper back navigation from cell VC?
    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//
//        KeychainHelper.shared.saveSelectedCountryCode(code: countries[indexPath.row].code)
//
//        //self.dismiss(animated: true, completion: nil)
//        //self.navigationController?.popViewController(animated: true)
//    }
}
