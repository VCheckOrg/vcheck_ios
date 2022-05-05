//
//  CheckDocInfoViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 04.05.2022.
//

import Foundation
import UIKit

class CheckDocInfoViewController : UIViewController {
    
    private let viewModel = CheckDocInfoViewModel()
    
    var firstPhoto: UIImage? = nil
    var secondPhoto: UIImage? = nil
    
    var docId: Int? = nil
    
    var dataList: [DocFieldWitOptPreFilledData] = []
    
    
    override func viewDidLoad() {
        
        let currLocaleCode = Locale.current.languageCode!
        
        viewModel.didReceiveDocInfoResponse = {
            
            
            if (self.viewModel.docInfoResponse != nil) {
                self.populateDocFields(preProcessedDocData: self.viewModel.docInfoResponse!,
                                  currentLocaleCode: currLocaleCode)
            }
        }
        
        viewModel.updateLoadingStatus = {
            if (self.viewModel.isLoading == true) {
                //self.activityIndicatorStart()
            } else {
               // self.activityIndicatorStop()
            }
        }
        
        viewModel.showAlertClosure = {
            let errText = self.viewModel.error?.errorText ?? "Error: No additional info"
            self.showToast(message: errText, seconds: 2.0)
        }
    }
    
    
    private func populateDocFields(preProcessedDocData: PreProcessedDocData, currentLocaleCode: String) {
        if ((preProcessedDocData.type?.fields?.count)! > 0) {
            print("GOT AUTO-PARSED FIELDS: \(String(describing: preProcessedDocData.type?.fields))")
            dataList = preProcessedDocData.type?.fields!.map { (element) -> (DocFieldWitOptPreFilledData) in
                    return convertDocFieldToOptParsedData(docField: element,
                                                          parsedDocFieldsData: preProcessedDocData.parsedData)
                } ?? []
//                let updatedAdapter = CheckDocInfoAdapter(ArrayList(dataList),
//                    this@CheckDocInfoFragment, currentLocaleCode)
//                binding.docInfoList.adapter = updatedAdapter
            } else {
                print("__NO__ AVAILABLE AUTO-PARSED FIELDS!")
            }
        }
    
}

//// MARK: - UITableViewDelegate
//extension CheckDocInfoViewController: UITableViewDelegate {
//
//    func tableView(_ countryListTable: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        LocalDatasource.shared.saveSelectedCountryCode(code: self.searchResultsList[indexPath.row].code)
//
//        self.dismiss(animated: true, completion: nil)
//    }
//}
//
//// MARK: - UITableViewDataSource
//extension CheckDocInfoViewController: UITableViewDataSource {
//
//    func tableView(_ countryListTable: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return searchResultsList.count
//    }
//
//    func tableView(_ countryListTable: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var cell = UITableViewCell.init()
//        if (searchResultsList[indexPath.row]).isBlocked {
//            cell = countryListTable.dequeueReusableCell(
//                withIdentifier: "blockedCountryCell", for: indexPath) as! BlockedCountryViewCell
//        } else {
//            cell = countryListTable.dequeueReusableCell(
//                withIdentifier: "allowedCountryCell", for: indexPath) as! AllowedCountryViewCell
//        }
//
//        if (cell is AllowedCountryViewCell) {
//            (cell as! AllowedCountryViewCell).setCountryName(name: self.searchResultsList[indexPath.row].name)
//            (cell as! AllowedCountryViewCell).setCountryFlag(flag: self.searchResultsList[indexPath.row].flag)
//        }
//        else {
//            (cell as! BlockedCountryViewCell).setCountryName(name: self.searchResultsList[indexPath.row].name)
//            (cell as! BlockedCountryViewCell).setCountryFlag(flag: self.searchResultsList[indexPath.row].flag)
//        }
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 70
//    }
//}


extension CheckDocInfoViewController {
    
    func composeConfirmedDocFieldsData() -> ParsedDocFieldsData {
        var data = ParsedDocFieldsData()
        dataList.forEach {
            if ($0.name == "date_of_birth") {
                data.dateOfBirth = $0.autoParsedValue
            }
            if ($0.name == "date_of_expiry") {
                data.dateOfExpiry = $0.autoParsedValue
            }
            if ($0.name == "name") {
                data.name = $0.autoParsedValue
            }
            if ($0.name == "surname") {
                data.surname = $0.autoParsedValue
            }
            if ($0.name == "number") {
                data.number = $0.autoParsedValue
            }
            if ($0.name == "og_name") {
                data.ogName = $0.autoParsedValue
            }
            if ($0.name == "og_surname") {
                data.ogSurname = $0.autoParsedValue
            }
        }
        return data
    }

    func convertDocFieldToOptParsedData(docField: DocField,
                                                parsedDocFieldsData: ParsedDocFieldsData?) -> DocFieldWitOptPreFilledData {
        var optParsedData = ""
        if (parsedDocFieldsData == nil) {
            return DocFieldWitOptPreFilledData(
                name: docField.name!, title: docField.title!,
                type: docField.type!, regex: docField.regex,
                autoParsedValue: "")
        } else {
            if (docField.name == "date_of_birth" && parsedDocFieldsData?.dateOfBirth != nil) {
                optParsedData = (parsedDocFieldsData?.dateOfBirth)!
            }
            if (docField.name == "date_of_expiry" && parsedDocFieldsData?.dateOfExpiry != nil) {
                optParsedData = (parsedDocFieldsData?.dateOfExpiry)!
            }
            if (docField.name == "name" && parsedDocFieldsData?.name != nil) {
                optParsedData = (parsedDocFieldsData?.name)!
            }
            if (docField.name == "surname" && parsedDocFieldsData?.surname != nil) {
                optParsedData = (parsedDocFieldsData?.surname)!
            }
            if (docField.name == "number" && parsedDocFieldsData?.number != nil) {
                optParsedData = (parsedDocFieldsData?.number)!
            }
            if (docField.name == "og_name" && parsedDocFieldsData?.ogName != nil) {
                optParsedData = (parsedDocFieldsData?.ogName)!
            }
            if (docField.name == "og_surname" && parsedDocFieldsData?.ogSurname != nil) {
                optParsedData = (parsedDocFieldsData?.ogSurname)!
            }
            return DocFieldWitOptPreFilledData(
                name: docField.name!, title: docField.title!, type: docField.type!,
                regex: docField.regex, autoParsedValue: optParsedData)
        }
    }
}
