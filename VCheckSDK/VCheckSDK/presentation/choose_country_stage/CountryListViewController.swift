//
//  CountryListViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 25.04.2022.
//

import Foundation
import UIKit


class CountryListViewController : UIViewController {
    
    @IBOutlet var countryListTable: CustomizableTableView!
    
    @IBOutlet weak var noSearchDataLabel: UILabel!
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBAction func navBackFromCountryList(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            if let bc = VCheckSDK.shared.backgroundSecondaryColorHex {
                self.searchBar.barTintColor = bc.hexToUIColor()
            }
            if let searchTextfield = self.searchBar.value(forKey: "searchField") as? UITextField  {
                searchTextfield.layer.borderColor = UIColor.lightGray.cgColor
                searchTextfield.layer.borderWidth = 1
                searchTextfield.layer.cornerRadius = 10
                searchTextfield.textColor = .white
                searchTextfield.leftView?.tintColor = .white
                if let tc1 = VCheckSDK.shared.secondaryTextColorHex {
                    searchTextfield.textColor = tc1.hexToUIColor()
                    searchTextfield.leftView?.tintColor = tc1.hexToUIColor()
                }
                if let tc2 = VCheckSDK.shared.primaryTextColorHex {
                    searchTextfield.textColor = tc2.hexToUIColor()
                    searchTextfield.leftView?.tintColor = tc2.hexToUIColor()
                }
                if let bc = VCheckSDK.shared.backgroundSecondaryColorHex {
                    searchTextfield.backgroundColor = bc.hexToUIColor()
                }
            }
        }
    }
    
    var countriesDataSourceArr: [CountryTO] = []
    
    var searchResultsList: [CountryTO] = []
    
    var parentVC: ChooseCountryViewController? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchResultsList = countriesDataSourceArr
        
        self.backBtn.setTitle("cancel".localized, for: .normal)
        
        self.noSearchDataLabel.text = "no_search_data_label".localized
        self.noSearchDataLabel.isHidden = true
        
        self.searchBar.delegate = self
        self.countryListTable.delegate = self
        self.countryListTable.dataSource = self
        
        if let bc = VCheckSDK.shared.backgroundSecondaryColorHex {
            self.countryListTable.setValue(bc.hexToUIColor() , forKey: "tableHeaderBackgroundColor")
        }
        
        self.searchResultsList = getSortedArr()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.parentVC!.reloadData()
    }
    
    func getSortedArr() -> [CountryTO] {
        let locale = Locale(identifier: VCheckSDK.shared.getSDKLangCode())
        return self.countriesDataSourceArr.sorted {
            return $0.name.compare($1.name, locale: locale) == .orderedAscending
        }
    }
}

// MARK: - UITableViewDelegate
extension CountryListViewController: UITableViewDelegate {
    
    func tableView(_ countryListTable: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        VCheckSDK.shared.setSelectedCountryCode(code: self.searchResultsList[indexPath.row].code)

        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension CountryListViewController: UITableViewDataSource {
        
    func tableView(_ countryListTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultsList.count
    }

    func tableView(_ countryListTable: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell.init()
        if (searchResultsList[indexPath.row]).isBlocked {
            cell = countryListTable.dequeueReusableCell(
                withIdentifier: "blockedCountryCell", for: indexPath) as! BlockedCountryViewCell
        } else {
            cell = countryListTable.dequeueReusableCell(
                withIdentifier: "allowedCountryCell", for: indexPath) as! AllowedCountryViewCell
        }
        
        if (cell is AllowedCountryViewCell) {
            if (self.searchResultsList[indexPath.row].code == "bm") {
                (cell as! AllowedCountryViewCell).setCountryName(name: NSLocalizedString("bermuda", comment: "")) //!
                (cell as! AllowedCountryViewCell).setCountryFlag(flag: self.searchResultsList[indexPath.row].flag)
            } else {
                if (self.searchResultsList[indexPath.row].name.lowercased().contains("&")) {
                    (cell as! AllowedCountryViewCell).setCountryName(name: self.searchResultsList[indexPath.row].name.replacingOccurrences(of: "&", with: "and"))
                    (cell as! AllowedCountryViewCell).setCountryFlag(flag: self.searchResultsList[indexPath.row].flag)
                } else {
                    (cell as! AllowedCountryViewCell).setCountryName(name: self.searchResultsList[indexPath.row].name)
                    (cell as! AllowedCountryViewCell).setCountryFlag(flag: self.searchResultsList[indexPath.row].flag)
                }
            }
        } else {
            (cell as! BlockedCountryViewCell).setCountryName(name: self.searchResultsList[indexPath.row].name)
            (cell as! BlockedCountryViewCell).setCountryFlag(flag: self.searchResultsList[indexPath.row].flag)
            (cell as! BlockedCountryViewCell).setNACountry()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

// MARK: - UISearchBarDelegate
extension CountryListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let countryName = searchBar.text else { return }
        searchCountries(forFragment: countryName)
        self.searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCountries(forFragment: searchText)
    }
    
    func searchCountries(forFragment: String) {
        
        if (forFragment.isEmpty) {
            self.searchResultsList = getSortedArr()
            self.noSearchDataLabel.isHidden = true
        } else {
            self.searchResultsList = self.countriesDataSourceArr.filter { $0.name.lowercased().contains(forFragment.lowercased())
            }
            if(self.searchResultsList.isEmpty) {
                self.noSearchDataLabel.isHidden = false
            } else {
                self.noSearchDataLabel.isHidden = true
            }
        }
        
        self.countryListTable.reloadData()
    }
}

