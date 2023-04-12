//
//  ChooseProviderViewController.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 12.04.2023.
//

import Foundation
import UIKit

class ChooseProviderViewController : UIViewController {
    
    @IBOutlet weak var backArrow: NonCustomizableIconView!
    
    @IBOutlet weak var tvTitle: PrimaryTextView!
    
    @IBOutlet weak var tvSubtitle: SecondaryTextView!
    
    @IBOutlet weak var providersTableView: CustomizableTableView!
    
    @IBAction func backAction(_ sender: Any) {
        if (VCheckSDK.shared.getProviderLogicCase() == ProviderLogicCase.ONE_PROVIDER_MULTIPLE_COUNTRIES ||
            VCheckSDK.shared.getProviderLogicCase() == ProviderLogicCase.MULTIPLE_PROVIDERS_PRESENT_COUNTRIES) {
            navigationController?.popViewController(animated: true) //?
        } else {
            // Stub; no back action required
        }
    }
    
    var providersList: [Provider]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tvTitle.text = "choose_provider_title".localized
        self.tvSubtitle.text = "choose_provider_description".localized
        
        if let bc = VCheckSDK.shared.backgroundSecondaryColorHex {
            self.providersTableView.setValue(bc.hexToUIColor() , forKey: "tableHeaderBackgroundColor")
        }
        
        if (VCheckSDK.shared.getProviderLogicCase() == ProviderLogicCase.ONE_PROVIDER_MULTIPLE_COUNTRIES ||
            VCheckSDK.shared.getProviderLogicCase() == ProviderLogicCase.MULTIPLE_PROVIDERS_PRESENT_COUNTRIES) {
            self.backArrow.isHidden = false
        } else {
            self.backArrow.isHidden = true
        }
        
        self.providersTableView.delegate = self
        self.providersTableView.dataSource = self
    }
}
    
// MARK: - UITableViewDelegate
extension ChooseProviderViewController: UITableViewDelegate {
    
    func tableView(_ countryListTable: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        VCheckSDK.shared.setSelectedProvider(provider: self.providersList![indexPath.row])

        self.performSegue(withIdentifier: "ChooseProviderToInitProvider", sender: nil)
    }
}

// MARK: - UITableViewDataSource
extension ChooseProviderViewController: UITableViewDataSource {
        
    func tableView(_ countryListTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providersList!.count
    }

    func tableView(_ countryListTable: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell.init()
        cell = countryListTable.dequeueReusableCell(
                withIdentifier: "providerViewCell", for: indexPath) as! ProviderViewCell
        
        if (self.providersList![indexPath.row].pRotocol != "vcheck") {
            (cell as! ProviderViewCell).setProviderTitle(name: self.providersList![indexPath.row].pRotocol.capitalized)
            (cell as! ProviderViewCell).setProviderSubitle(name: "")
        } else {
            (cell as! ProviderViewCell).setProviderTitle(name: "VCHECK")
            (cell as! ProviderViewCell).setProviderSubitle(name: "vcheck_provider_description".localized)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94
    }
}
