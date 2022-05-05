//
//  CheckDocInfoViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 04.05.2022.
//

import Foundation
import UIKit

class CheckDocInfoViewController : UIViewController {
    
    
    @IBOutlet weak var docFieldsTableView: UITableView!
    
    @IBOutlet weak var firlsPhotoImageView: UIImageView!
    
    @IBOutlet weak var secondPhotoImageView: UIImageView!
    
    
    private let viewModel = CheckDocInfoViewModel()
    
    var firstPhoto: UIImage? = nil
    var secondPhoto: UIImage? = nil
    
    var docId: Int? = nil
    
    var fieldsList: [DocFieldWitOptPreFilledData] = []
    
    let currLocaleCode = Locale.current.languageCode!
    
    
    override func viewDidLoad() {
        
        viewModel.didReceiveDocInfoResponse = {
            
            if (self.viewModel.docInfoResponse != nil) {
                self.populateDocFields(preProcessedDocData: self.viewModel.docInfoResponse!,
                                       currentLocaleCode: self.currLocaleCode)
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
            fieldsList = preProcessedDocData.type?.fields!.map { (element) -> (DocFieldWitOptPreFilledData) in
                    return convertDocFieldToOptParsedData(docField: element,
                                                          parsedDocFieldsData: preProcessedDocData.parsedData)
                } ?? []
            docFieldsTableView.reloadData()
            } else {
                print("__NO__ AVAILABLE AUTO-PARSED FIELDS!")
            }
        }
    
}

// MARK: - UITableViewDataSource
extension CheckDocInfoViewController: UITableViewDataSource {

    func tableView(_ countryListTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fieldsList.count
    }

    func tableView(_ countryListTable: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = docFieldsTableView.dequeueReusableCell(withIdentifier: "docFieldCell") as! DocInfoViewCell
        
        let field: DocFieldWitOptPreFilledData = fieldsList[indexPath.row]
        
        var title = ""
        switch(currLocaleCode) {
            case "uk": title = field.title.uk!
            case "ru": title = field.title.ru!
            default: title = field.title.en!
        }
        
        cell.docFieldTitle.text = title
        
        let fieldName = fieldsList[indexPath.row].name

        let editingChanged = UIAction { _ in
            
            self.fieldsList = self.fieldsList.map {
                $0.name == fieldName ? $0.modifyAutoParsedValue(with: cell.docTextField.text!) : $0 }
        }
        
        cell.docTextField.addAction(editingChanged, for: .editingChanged)

        return cell
    }

//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 70
//    }
    
    @objc final private func onDocCellTextChanged(textField: UITextField) {

    }
}


extension CheckDocInfoViewController {
    
    func composeConfirmedDocFieldsData() -> ParsedDocFieldsData {
        var data = ParsedDocFieldsData()
        fieldsList.forEach {
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


//// MARK: - UITableViewDelegate
//extension CheckDocInfoViewController: UITableViewDelegate {
//
//    func tableView(_ countryListTable: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        self.dismiss(animated: true, completion: nil)
//    }
//}
