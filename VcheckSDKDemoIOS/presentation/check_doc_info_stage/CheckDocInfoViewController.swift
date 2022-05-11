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
    
    var fieldsList: [DocFieldWitOptPreFilledData] = []
    
    let currLocaleCode = Locale.current.languageCode!
    
    //TODO: stretch parent on table view size change (actual doc fields count)!
    @IBOutlet weak var docFieldsTableView: UITableView!
    
    @IBOutlet weak var firstPhotoImageView: UIImageView!
    @IBOutlet weak var secondPhotoImageView: UIImageView!
    
    @IBOutlet weak var secondPhotoImgCard: RoundedView!
    
    @IBOutlet weak var parentCardHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBAction func submitDocAction(_ sender: UIButton) {
        self.checkDocFieldsAndPerformConfirmation()
    }
    
    override func viewDidLoad() {
        
        docFieldsTableView.dataSource = self
        
        firstPhotoImageView.image = firstPhoto
        
        if (secondPhoto != nil) {
            secondPhotoImageView.isHidden = false
            secondPhotoImageView.image = secondPhoto
        } else {
            secondPhotoImgCard.isHidden = true
            tableTopConstraint.constant = 30
        }
        
        viewModel.didReceiveDocInfoResponse = {
            if (self.viewModel.docInfoResponse != nil) {
                self.populateDocFields(preProcessedDocData: self.viewModel.docInfoResponse!,
                                       currentLocaleCode: self.currLocaleCode)
            }
        }
        
        viewModel.didReceiveConfirmedResponse = {
            if (self.viewModel.confirmedDocResponse == true) {
                self.performSegue(withIdentifier: "CheckInfoToLivenessInstr", sender: nil)
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
        
        if (self.docId == nil) {
            let errText = "Error: Cannot find document id for navigation!"
            self.showToast(message: errText, seconds: 2.0)
        } else {
            viewModel.getDocumentInfo(docId: self.docId!)
        }
        
    }
    
    
    private func populateDocFields(preProcessedDocData: PreProcessedDocData, currentLocaleCode: String) {
        if ((preProcessedDocData.type?.fields?.count)! > 0) {
                        
            let additionalHeight = CGFloat((preProcessedDocData.type?.fields?.count)! * 82)
            
            if (secondPhoto == nil) {
                parentCardHeightConstraint.constant = parentCardHeightConstraint.constant + additionalHeight
                    - tableViewHeightConstraint.constant - 250 // * - 2nd (missing) card height - 20
            } else {
                parentCardHeightConstraint.constant = parentCardHeightConstraint.constant + additionalHeight
                    - tableViewHeightConstraint.constant
            }
            
            tableViewHeightConstraint.constant = additionalHeight
            
            
            print("GOT AUTO-PARSED FIELDS: \(String(describing: preProcessedDocData.type?.fields))")
            fieldsList = preProcessedDocData.type?.fields!.map { (element) -> (DocFieldWitOptPreFilledData) in
                    return convertDocFieldToOptParsedData(docField: element,
                                                          parsedDocFieldsData: preProcessedDocData.parsedData)
                } ?? []
            print("GOT FIELDS LIST: \(fieldsList)")
            docFieldsTableView.reloadData()
            } else {
                print("__NO__ AVAILABLE AUTO-PARSED FIELDS!")
            }
        }
    
    func checkDocFieldsAndPerformConfirmation() {
        var noEmptyFields: Bool = true
        
        fieldsList.forEach {
            if ($0.autoParsedValue.isEmpty) {
                noEmptyFields = false
            }
        }
        
        if (noEmptyFields == true) {
            let composedFieldsData = self.composeConfirmedDocFieldsData()
            self.viewModel.updateAndConfirmDocument(docId: self.docId!,
                                                    parsedDocFieldsData: composedFieldsData)
        } else {
            self.showToast(message: NSLocalizedString("error_some_fields_are_empty", comment: ""), seconds: 2.0)
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
        
        cell.docTextField.text = field.autoParsedValue
        cell.docTextField.returnKeyType = UIReturnKeyType.done
        cell.docTextField.delegate = self
        
        let fieldName = fieldsList[indexPath.row].name

        let editingChanged = UIAction { _ in
            self.fieldsList = self.fieldsList.map {
                $0.name == fieldName ? $0.modifyAutoParsedValue(with: cell.docTextField.text!) : $0 }
        }
        
        if(fieldName == "name") {
            cell.docTextField.addTarget(self, action: #selector(self.onDocNameFieldChanged(_:)),
                                        for: UIControl.Event.editingChanged)
        }

        cell.docTextField.addAction(editingChanged, for: .editingChanged)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82
    }
    
    @objc final private func onDocNameFieldChanged(_ textField: UITextField) {
        if(textField.text!.count < 3) {
            textField.text = "Введите валидное имя"
        }
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

extension UIViewController: UITextFieldDelegate{
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}
