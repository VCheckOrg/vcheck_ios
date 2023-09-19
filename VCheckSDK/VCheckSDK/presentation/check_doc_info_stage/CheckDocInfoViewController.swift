//
//  CheckDocInfoViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 04.05.2022.
//

import Foundation
import UIKit
@_implementationOnly import Alamofire


class CheckDocInfoViewController : UIViewController {
    
    private let viewModel = CheckDocInfoViewModel()
    
    var docId: Int? = nil
    
    var isDocCheckForced: Bool = false
        
    var regex: String?
    
    var fieldsList: [DocFieldWitOptPreFilledData] = []
    
    let currLocaleCode = VCheckSDK.shared.getSDKLangCode()
    
    @IBOutlet weak var docFieldsTableView: UITableView!
    
    @IBOutlet weak var firstPhotoImageView: UIImageView!
    @IBOutlet weak var secondPhotoImageView: UIImageView!
    
    @IBOutlet weak var secondPhotoImgCard: VCheckSDKRoundedView!
    
    @IBOutlet weak var parentCardHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var docInfoScrollView: UIScrollView!
        
    
    @IBAction func submitDocAction(_ sender: UIButton) {
        self.checkDocFieldsAndPerformConfirmation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        
        self.docFieldsTableView.dataSource = self
        
        if let bc = VCheckSDK.shared.backgroundSecondaryColorHex {
            self.docFieldsTableView.setValue(bc.hexToUIColor() , forKey: "tableHeaderBackgroundColor")
            //self.tableFooterView.backgroundColor = bc.hexToUIColor()
        }

        viewModel.didReceiveDocInfoResponse = {
            if (self.viewModel.docInfoResponse != nil) {
                
                self.populateDocFields(preProcessedDocData: self.viewModel.docInfoResponse!,
                                       currentLocaleCode: self.currLocaleCode)
                
                self.populateDocImages(data: self.viewModel.docInfoResponse!)
            }
        }
        
        viewModel.didReceiveConfirmedResponse = {
            if (self.viewModel.confirmedDocResponse == true) {
                self.viewModel.getCurrentStage()
            }
        }
        
        viewModel.didReceivedCurrentStage = {
            if (self.viewModel.currentStageResponse?.data?.config != nil) {
                VCheckSDKLocalDatasource.shared.setLivenessMilestonesList(list:
                    (self.viewModel.currentStageResponse?.data?.config?.gestures)!)
                self.performSegue(withIdentifier: "CheckDocInfoToLivenessInstr", sender: nil)
            } else if (VCheckSDK.shared.getVerificationType() == VerificationSchemeType.DOCUMENT_UPLOAD_ONLY) {
                VCheckSDK.shared.finish(executePartnerCallback: true)
            }
        }
        
        viewModel.showAlertClosure = {
            //TODO: move to util method (?)
            if (self.viewModel.error?.errorCode != BaseClientErrors.PRIMARY_DOCUMENT_EXISTS_OR_USER_INTERACTION_COMPLETED) {
                self.showToast(message: "Error: \(String(describing: self.viewModel.error?.errorText ?? ""))"
                               + " [\(String(describing: self.viewModel.error?.errorCode))]", seconds: 3.0)
            } else {
                self.showToast(message: "check_doc_fields_input_message".localized, seconds: 3.0)
            }
        }
        
        if (self.docId == nil) {
            self.showToast(message: "invalid_doc_type_desc".localized, seconds: 3.0)
        } else {
            viewModel.getDocumentInfo(docId: self.docId!)
        }
    }
    
    private func populateDocImages(data: PreProcessedDocData) {
        
        var baseURL: String = ""
        
        if (VCheckSDK.shared.getEnvironment() == VCheckEnvironment.DEV) {
            baseURL = VCheckSDKConstants.API.devVerificationServiceUrl
        } else {
            baseURL = VCheckSDKConstants.API.partnerVerificationServiceUrl
        }
                
        if (data.images != nil && !data.images!.isEmpty) {
            self.requestDocImageForResult(imgIdx: 0, imgURL: data.images![0], baseURL: baseURL)
            if (data.images!.count > 1) {
                self.secondPhotoImageView.isHidden = false
                self.requestDocImageForResult(imgIdx: 1, imgURL: data.images![1], baseURL: baseURL)
            } else {
                self.secondPhotoImgCard.isHidden = true
                self.tableTopConstraint.constant = 30
            }
        }
    }
    
    private func requestDocImageForResult(imgIdx: Int, imgURL: String, baseURL: String) {
        
        let token = VCheckSDK.shared.getVerificationToken()
        if (token.isEmpty) {
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]
        
        AF.request(baseURL + imgURL, method: .get, headers: headers).response{ response in
           switch response.result {
            case .success(let responseData):
               if (imgIdx == 0) {
                   self.firstPhotoImageView.image = UIImage(data: responseData!, scale: 1)
               } else {
                   self.secondPhotoImageView.image = UIImage(data: responseData!, scale: 1)
               }
            case .failure(let error):
                print("VCheckSDK - Error: ", error)
            }
        }
    }
    
    
    private func populateDocFields(preProcessedDocData: PreProcessedDocData, currentLocaleCode: String) {
        if ((preProcessedDocData.type?.fields?.count)! > 0) {
            
            var additionalHeight = 0.0
            
            if ((preProcessedDocData.type?.fields?.count)! <= 4) {
                additionalHeight = CGFloat((preProcessedDocData.type?.fields?.count)! * 82) + 15
            } else {
                additionalHeight = CGFloat((preProcessedDocData.type?.fields?.count)! * 82)
            }
            
            
            if (preProcessedDocData.images?.count == 1) {
                parentCardHeightConstraint.constant = parentCardHeightConstraint.constant + additionalHeight
                    - tableViewHeightConstraint.constant - 250 // * - 2nd (missing) card height - 20
            } else {
                parentCardHeightConstraint.constant = parentCardHeightConstraint.constant + additionalHeight
                    - tableViewHeightConstraint.constant
            }
            
            tableViewHeightConstraint.constant = additionalHeight
            
            fieldsList = preProcessedDocData.type?.fields!.map { (element) -> (DocFieldWitOptPreFilledData) in
                    return convertDocFieldToOptParsedData(docField: element,
                                                          parsedDocFieldsData: preProcessedDocData.parsedData)
                } ?? []
            docFieldsTableView.reloadData()
            } else {
                print("VCheckSDK: no available auto-parsed fields")
            }
        }
    
    func checkDocFieldsAndPerformConfirmation() {
                
        let noInvalidFields: Bool = checkIfAnyFieldIsNotValid()
        
        if (noInvalidFields == false) {
            let composedFieldsData = self.composeConfirmedDocFieldsData()
            self.viewModel.updateAndConfirmDocument(docId: self.docId!,
                                                    parsedDocFieldsData: composedFieldsData)
        } else {
            self.showToast(message: "error_some_fields_are_empty".localized, seconds: 2.0)
        }
    }
    
    private func checkIfAnyFieldIsNotValid() -> Bool {
        var hasValidationErrors: Bool = false
        for item in self.fieldsList {
            if item.autoParsedValue.count < 2 {
                hasValidationErrors = true
            }
            if !isFieldValid(fieldInfo: item) {
                hasValidationErrors = true
            }
        }
        return hasValidationErrors
    }

    private func isFieldValid(fieldInfo: DocFieldWitOptPreFilledData) -> Bool {
        if let regex = fieldInfo.regex, !NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: fieldInfo.autoParsedValue) {
            return false
        } else {
            if (fieldInfo.name == "date_of_birth" || fieldInfo.name == "expiration_date")
                && !(fieldInfo.autoParsedValue).checkIfValidDocDateFormat() {
                return false
            } else {
                if fieldInfo.autoParsedValue.count < 3 {
                    return false
                }
            }
        }
        return true
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
        
        if let pct = (VCheckSDK.shared.primaryTextColorHex) {
            cell.docTextField.textColor = pct.hexToUIColor()
        }
        
        var title = ""
        switch(currLocaleCode) {
            case "uk": title = field.title.uk!
            case "ru": title = field.title.ru!
            case "pl": title = field.title.pl!
            default: title = field.title.en!
        }
        
        cell.docFieldTitle.text = title
        
        cell.docTextField.text = field.autoParsedValue
        cell.docTextField.returnKeyType = UIReturnKeyType.done
        cell.docTextField.delegate = self
        
        let fieldName = fieldsList[indexPath.row].name
        
        if (fieldName == "date_of_birth" || fieldName == "expiration_date") {
            cell.docTextField.keyboardType = .numberPad
        } else {
            cell.docTextField.keyboardType = .default
        }

        let editingChanged = UIAction { _ in
            self.fieldsList = self.fieldsList.map {
                $0.name == fieldName ? $0.modifyAutoParsedValue(with: cell.docTextField.text!) : $0 }
        }
        
        cell.docTextField.addAction(editingChanged, for: .editingChanged)
        
        
        if (fieldName == "name") {
            cell.docTextField.addTarget(self, action: #selector(self.validateDocNameField(_:)),
                                        for: UIControl.Event.editingChanged)
        }
        
        if (fieldName == "surname") {
            cell.docTextField.addTarget(self, action: #selector(self.validateDocSurnameField(_:)),
                                        for: UIControl.Event.editingChanged)
        }
        
        if (fieldName == "date_of_birth") {
            var hintColor: UIColor? = nil
            if let pc = VCheckSDK.shared.secondaryTextColorHex {
                hintColor = pc.hexToUIColor()
            } else {
                hintColor = UIColor.white
            }
            cell.docTextField.attributedPlaceholder = NSAttributedString(
                string: "doc_date_placeholder".localized,
                attributes: [NSAttributedString.Key.foregroundColor: hintColor!])
            cell.docTextField.addTarget(self, action: #selector(self.validateDocDateOfBirthField(_:)),
                                        for: UIControl.Event.editingChanged)
        }
        
        if (fieldName == "expiration_date") {
            var hintColor: UIColor? = nil
            if let pc = VCheckSDK.shared.secondaryTextColorHex {
                hintColor = pc.hexToUIColor()
            } else {
                hintColor = UIColor.white
            }
            cell.docTextField.attributedPlaceholder = NSAttributedString(
                string: "doc_date_placeholder".localized,
                attributes: [NSAttributedString.Key.foregroundColor: hintColor!])
            cell.docTextField.addTarget(self, action: #selector(self.validateDocExpirationDate(_:)),
                                        for: UIControl.Event.editingChanged)
        }
        
        if (fieldName == "number") {
            self.regex = field.regex
            cell.docTextField.addTarget(self, action: #selector(self.validateDocNumberField(_:)),
                                        for: UIControl.Event.editingChanged)
        }
        
        let setMaskedDate = UIAction { _ in
            cell.docTextField.text = self.formattedNumber(number: cell.docTextField.text)
        }
        if (fieldName == "date_of_birth") {
            cell.docTextField.addAction(setMaskedDate, for: .editingChanged)
        }
        if (fieldName == "expiration_date") {
            cell.docTextField.addAction(setMaskedDate, for: .editingChanged)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82
    }
    
    @objc final private func validateDocNameField(_ textField: UITextField) {
        if (textField.text!.count < 2 || (self.regex != nil && (!textField.text!.isMatchedBy(regex: self.regex!)))) {
            textField.setError("enter_valid_name".localized)
        } else {
            textField.setError(show: false)
        }
    }
    
    @objc final private func validateDocSurnameField(_ textField: UITextField) {
        if (textField.text!.count < 2 || (self.regex != nil && (!textField.text!.isMatchedBy(regex: self.regex!)))) {
            textField.setError("enter_valid_surname".localized)
        } else {
            textField.setError(show: false)
        }
    }
    
    @objc final private func validateDocExpirationDate(_ textField: UITextField) {
        if (!String(textField.text!.prefix(10)).checkIfValidDocDateFormat()) {
            textField.setError("enter_valid_exp_date".localized)
        } else {
            textField.setError(show: false)
        }
    }
    
    @objc final private func validateDocDateOfBirthField(_ textField: UITextField) {
        if (!String(textField.text!.prefix(10)).checkIfValidDocDateFormat()) {
            textField.setError("enter_valid_dob".localized)
        } else {
            textField.setError(show: false)
        }
    }
    
    @objc final private func validateDocNumberField(_ textField: UITextField) {
        if(self.regex != nil && (!textField.text!.isMatchedBy(regex: self.regex!))) {
            textField.setError("enter_valid_doc_number".localized)
        } else {
            textField.setError(show: false)
        }
    }
    
    func formattedNumber(number: String?) -> String {
                    let cleanNumber = number!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                    let mask = "####-##-##"
                    var result = ""
                    var index = cleanNumber.startIndex
        for ch in mask where index < cleanNumber.endIndex {
                        if ch == "#" {
                            result.append(cleanNumber[index])
                            index = cleanNumber.index(after: index)
                        } else {
                            result.append(ch)
                        }
                    }
                    return result
                }
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(keyboardWillShow(notification:)),
                                             name: UIResponder.keyboardWillShowNotification,
                                             object: nil)
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(keyboardWillHide(notification:)),
                                             name: UIResponder.keyboardWillHideNotification,
                                             object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // keyboardFrameEndUserInfoKey
        let keyboardSize = keyboardInfo.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        self.docInfoScrollView.contentInset = contentInsets
        self.docInfoScrollView.scrollIndicatorInsets = contentInsets
        
        var diff = 0.0
        if (self.viewModel.docInfoResponse?.images?.count ?? 1 > 1) {
            diff = keyboardSize.height - 130.0
        } else {
            diff = keyboardSize.height - 270.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100) ) {
            self.docInfoScrollView.setContentOffset(CGPoint(x: self.view.frame.minX,
                                                            y: self.tableViewHeightConstraint.constant + diff),
                                                            animated: true)
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.docInfoScrollView.contentInset = .zero
        self.docInfoScrollView.scrollIndicatorInsets = .zero
    }
    
    
}


extension CheckDocInfoViewController {
    
    func composeConfirmedDocFieldsData() -> DocUserDataRequestBody {
        var data = ParsedDocFieldsData()
        fieldsList.forEach {
            if ($0.name == "date_of_birth") {
                data.dateOfBirth = String($0.autoParsedValue.prefix(10))
            }
            if ($0.name == "expiration_date") {
                data.dateOfExpiry = String($0.autoParsedValue.prefix(10))
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
        }
        return DocUserDataRequestBody(data: data, isForced: self.isDocCheckForced)
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
            if (docField.name == "expiration_date" && parsedDocFieldsData?.dateOfExpiry != nil) {
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
            return DocFieldWitOptPreFilledData(
                name: docField.name!, title: docField.title!, type: docField.type!,
                regex: docField.regex, autoParsedValue: optParsedData)
        }
    }
}

extension UIViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//TODO: improve UX
//        viewModel.updateLoadingStatus = {
//            if (self.viewModel.isLoading == true) {
//                //self.activityIndicatorStart()
//            } else {
//               // self.activityIndicatorStop()
//            }
//        }
