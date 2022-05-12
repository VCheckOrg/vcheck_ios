//
//  CountryListViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 25.04.2022.
//

import Foundation
import UIKit
import Localize_Swift

class CountryListViewController : UIViewController {
    
    @IBOutlet var countryListTable: UITableView!
    
    @IBOutlet weak var noSearchDataLabel: UILabel!
    
    @IBAction func navBackFromCountryList(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet{
            if let searchTextfield = self.searchBar.value(forKey: "searchField") as? UITextField  {
                searchTextfield.layer.borderColor = UIColor.lightGray.cgColor
                searchTextfield.layer.borderWidth = 1
                searchTextfield.layer.cornerRadius = 10
                searchTextfield.textColor = .white
                searchTextfield.leftView?.tintColor = .white
            }
        }
    }
    
    var countriesDataSourceArr: [CountryTO] = []
    
    var searchResultsList: [CountryTO] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.countriesDataSourceArr = countriesDataSourceArr.sorted { $0.name < $1.name }
        self.searchResultsList = countriesDataSourceArr
        
        noSearchDataLabel.isHidden = true
        
        searchBar.delegate = self
        countryListTable.delegate = self
        countryListTable.dataSource = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let firstVC = presentingViewController as? ChooseCountryViewController {
            DispatchQueue.main.async {
                firstVC.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension CountryListViewController: UITableViewDelegate {
    
    func tableView(_ countryListTable: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        LocalDatasource.shared.saveSelectedCountryCode(code: self.searchResultsList[indexPath.row].code)

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
            (cell as! AllowedCountryViewCell).setCountryName(name: self.searchResultsList[indexPath.row].name)
            (cell as! AllowedCountryViewCell).setCountryFlag(flag: self.searchResultsList[indexPath.row].flag)
        }
        else {
            (cell as! BlockedCountryViewCell).setCountryName(name: self.searchResultsList[indexPath.row].name)
            (cell as! BlockedCountryViewCell).setCountryFlag(flag: self.searchResultsList[indexPath.row].flag)
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
            self.searchResultsList = self.countriesDataSourceArr
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

