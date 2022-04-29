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
    
    var countries: [CountryTO] = []
    
    override func viewDidLoad() {
        
        if let selectedCountry = countries.first(where: { $0.code == KeychainHelper.shared.readSelectedCountryCode() }) {
            tvSelectedCountryName.text = selectedCountry.name
            tvSelectedCountryFlag.text = selectedCountry.flag
       } else {
           print("COUNTRY NOT FOUND IN KEYCHAIN")
           tvSelectedCountryName.text = countries[0].name
           tvSelectedCountryFlag.text = countries[0].flag
        }
        
        preSelectedCountryView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector (self.navigateToList (_:))))
    }
    
    
    @objc func navigateToList(_ sender:UITapGestureRecognizer){

       // this is the function that lets us perform the segue
       performSegue(withIdentifier: "CountryToList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "CountryToList") {
            let vc = segue.destination as! CountryListViewController
            vc.countries = self.countries
        }
    }
}
