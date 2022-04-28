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
    
    let countries = [
        "Украина", "Англия", "Франция", "Италия", "Германия", "Украина", "Англия", "Франция", "Италия", "Германия", "Англия", "Франция", "Италия", "Германия"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countryListTable.delegate = self
        countryListTable.dataSource = self
    }
}

extension CountryListViewController: UITableViewDelegate {
    func tableView(_ countryListTable: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(countries[indexPath.row])
    }
}

extension CountryListViewController: UITableViewDataSource {
    func tableView(_ countryListTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }

    func tableView(_ countryListTable: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = countryListTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = countries[indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
}

