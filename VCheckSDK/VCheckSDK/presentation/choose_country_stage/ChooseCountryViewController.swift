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
        
        self.continueButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector (self.navigateToProviderLogic (_:))))
    }
    
    func reloadData() {
        if let selectedCountry = countries.first(where: {
            if (VCheckSDK.shared.getOptSelectedCountryCode() != nil) {
                return $0.code == VCheckSDK.shared.getOptSelectedCountryCode()
            } else if (countries.contains(where: { $0.code == "ua" })) {
                return $0.code == "ua"
            } else {
                return true
            }
        }) {
            
            VCheckSDK.shared.setOptSelectedCountryCode(code: selectedCountry.code)
            
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
    
    @objc func navigateToProviderLogic(_ sender:UITapGestureRecognizer){
        switch VCheckSDK.shared.getProviderLogicCase() {
            case ProviderLogicCase.ONE_PROVIDER_MULTIPLE_COUNTRIES:
                self.performSegue(withIdentifier: "CountriesToInitProvider", sender: nil)
            case ProviderLogicCase.MULTIPLE_PROVIDERS_PRESENT_COUNTRIES:
                let countryCode = VCheckSDK.shared.getOptSelectedCountryCode()!
                let distinctProvidersList: [Provider] = VCheckSDK.shared.getAllAvailableProviders().filter {
                    $0.countries?.contains(countryCode) ?? false
                }
                self.performSegue(withIdentifier: "CountriesToChooseProvider", sender: distinctProvidersList)
            default:
                showToast(message: "Error: country options should not be available for that provider", seconds: 4.0)
                break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "CountryToList") {
            let vc = segue.destination as! CountryListViewController
            vc.countriesDataSourceArr = self.countries
            vc.parentVC = self
        }
        if (segue.identifier == "CountriesToChooseProvider") {
            let vc = segue.destination as! ChooseProviderViewController
            vc.providersList = sender as? [Provider]
        }
    }

}
