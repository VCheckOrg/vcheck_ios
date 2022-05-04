//
//  ChooseCountryViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 25.04.2022.
//

import Foundation
import UIKit

//TODO: cleanup domain directory!

class ChooseCountryViewController : UIViewController {
    
    @IBOutlet weak var preSelectedCountryView: UIView!
    
    @IBOutlet weak var tvSelectedCountryName: UILabel!
    
    @IBOutlet weak var tvSelectedCountryFlag: UITextView!
    
    @IBAction func navToDocType(_ sender: Any) {
        //TODO: remove obsolete action?
    }
    
    var countries: [CountryTO] = []
    
    override func viewDidLoad() {
        
        reloadData()
        
        preSelectedCountryView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector (self.navigateToList (_:))))
    }
    
    func reloadData() {
        if let selectedCountry = countries.first(where: { $0.code == LocalDatasource.shared.readSelectedCountryCode() }) {
            tvSelectedCountryName.text = selectedCountry.name
            tvSelectedCountryFlag.text = selectedCountry.flag
       } else {
           print("COUNTRY NOT FOUND IN KEYCHAIN")
           tvSelectedCountryName.text = countries[0].name
           tvSelectedCountryFlag.text = countries[0].flag
        }
    }
    
    @objc func navigateToList(_ sender:UITapGestureRecognizer){
       performSegue(withIdentifier: "CountryToList", sender: self)
    }
    
//    @objc func navigateToChooDocType(_ sender:UITapGestureRecognizer){
//       performSegue(withIdentifier: "CountryToChooseDocType", sender: self)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "CountryToList") {
            let vc = segue.destination as! CountryListViewController
            vc.countriesDataSourceArr = self.countries
        }
        if (segue.identifier == "CountryToChooseDocType") {
            //let vc = segue.destination as! ChooseDocTypeViewController
            //vc.countriesDataSourceArr = self.countries
        }
    }
}
