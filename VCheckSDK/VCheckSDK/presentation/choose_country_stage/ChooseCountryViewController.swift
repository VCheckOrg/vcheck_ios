//
//  ChooseCountryViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 25.04.2022.
//

import Foundation
import UIKit

class ChooseCountryViewController : UIViewController {
    
    @IBOutlet weak var preSelectedCountryView: SmallRoundedView!
    
    @IBOutlet weak var tvSelectedCountryName: SecondaryTextView!
    
    @IBOutlet weak var tvSelectedCountryFlag: FlagView!
    
    @IBOutlet weak var continueButton: UIButton!
    
    var countries: [CountryTO] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reloadData()
        
        self.continueButton.setTitle("proceed".localized, for: .normal)
        
        self.preSelectedCountryView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector (self.navigateToList (_:))))
    }
    
    func reloadData() {
        if let selectedCountry = countries.first(where: { $0.code == VCheckSDK.shared.getSelectedCountryCode() }) {
            
            if (selectedCountry.code == "bm") {
                tvSelectedCountryName.text = "bermuda".localized
                tvSelectedCountryFlag.text = selectedCountry.flag
            } else {
                if (selectedCountry.name.lowercased().contains("&")) {
                    tvSelectedCountryName.text = selectedCountry.name.replacingOccurrences(of: "&", with: "and")
                    tvSelectedCountryFlag.text = selectedCountry.flag
                } else {
                    tvSelectedCountryName.text = selectedCountry.name
                    tvSelectedCountryFlag.text = selectedCountry.flag
                }
            }
            
       } else {
           tvSelectedCountryName.text = countries[0].name
           tvSelectedCountryFlag.text = countries[0].flag
       }
    }
    
    @objc func navigateToList(_ sender:UITapGestureRecognizer){
       performSegue(withIdentifier: "CountryToList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "CountryToList") {
            let vc = segue.destination as! CountryListViewController
            vc.countriesDataSourceArr = self.countries
            vc.parentVC = self
        }
    }
}
