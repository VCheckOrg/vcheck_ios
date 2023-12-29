//
//  PartnerFormController.swift
//  Demo
//
//  Created by Kirill Kaun on 28.12.2023.
//

import Foundation
import UIKit

class PartnerFormController : UIViewController {
    
    @IBOutlet weak var pageTitle: UITextView!
    @IBOutlet weak var descr: UITextView!
    
    @IBOutlet weak var companyLabel: UITextView!
    @IBOutlet weak var emailLabel: UITextView!
    @IBOutlet weak var nameLabel: UITextView!
    @IBOutlet weak var phoneLabel: UITextView!
    @IBOutlet weak var agreeLabel: UITextView!
    
    @IBOutlet weak var fieldCompanyName: UITextField!
    @IBOutlet weak var fieldCompanyEmail: UITextField!
    @IBOutlet weak var fieldPersonName: UITextField!
    @IBOutlet weak var fieldPersonPhone: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    //TODO: fix or replace checkbox package; has Swift-related compilation errors
    //@IBOutlet weak var checkbox: Checkbox!
    //@IBOutlet weak var checkBoxAgreeDescr: UITextView!
    
    @IBAction func actionSendFormAttempt(_ sender: Any) {
        sendFormRequest()
    }
    
    @IBOutlet weak var sendBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageTitle.text = "partner_inv_title".localized
        descr.text = "partner_inv_form_descr".localized
        companyLabel.text = "partner_inv_company".localized
        nameLabel.text = "partner_inv_name".localized
        phoneLabel.text = "partner_inv_phone".localized
        emailLabel.text = "partner_inv_email".localized
        sendBtn.setTitle("send".localized, for: .normal)
        
        fieldPersonName.delegate = self
        fieldPersonPhone.delegate = self
        fieldCompanyEmail.delegate = self
        fieldCompanyName.delegate = self
        fieldPersonPhone.keyboardType = .phonePad
        
//        checkbox.checkedBorderColor = .systemBlue
//        checkbox.borderStyle = .square
//        checkbox.checkmarkColor = .systemBlue
//        checkbox.checkmarkStyle = .tick
//        checkbox.increasedTouchRadius = 10
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    private func sendFormRequest() {
        if (areChecksPassed()) {
            self.sendBtn.isHidden = true
            RemoteDatasource.shared.createVerificationRequest(
                model: PartnerApplicationRequestData.init(company: (fieldCompanyName?.text)!,
                                                          email: (fieldCompanyEmail.text)!,
                                                          name: (fieldPersonName?.text)!,
                                                          phone: fieldPersonPhone?.text ?? ""),
                completion: { (success, errorStr) in
                    DispatchQueue.main.async {
                        if (success == true) {
                            self.showAlertOnSuccess()
                        } else {
                            self.sendBtn.isHidden = false
                            self.sendBtn.setTitle("send".localized, for: .normal)
                            self.showToast(message: "partner_form_request_error".localized, seconds: 2)
                        }
                    }
                })
        } else {
            self.sendBtn.isHidden = false
            self.sendBtn.setTitle("send".localized, for: .normal)
        }
    }
    
    
    private func areChecksPassed() -> Bool {
        if (isNotMinialLength(fieldCompanyName?.text)) {
            fieldCompanyName.setErrorAndroidLike("et_enter_valid_company".localized)
            return false
        } else {
            fieldCompanyName.setErrorAndroidLike(nil, show: false)
        }
        if (!isValidEmail(fieldCompanyEmail.text)) {
            fieldCompanyEmail.setErrorAndroidLike("et_enter_valid_email".localized)
            return false
        } else {
            fieldCompanyEmail.setErrorAndroidLike(nil, show: false)
        }
        if (isNotMinialLength(fieldPersonName?.text)) {
            fieldPersonName.setErrorAndroidLike("et_enter_valid_name".localized)
            return false
        } else {
            fieldPersonName.setErrorAndroidLike(nil, show: false)
        }
        if (fieldPersonPhone.text != nil && !fieldPersonPhone.text!.isEmpty
                && !isValidPhone(fieldPersonPhone.text)) {
            fieldPersonPhone.setErrorAndroidLike("et_enter_valid_phone".localized)
            return false
        } else {
            fieldPersonPhone.setErrorAndroidLike(nil, show: false)
        }
//        if (!checkbox.isChecked) {
//            showToast(message: "agreement_not_checked".localized, seconds: 2)
//            return false
//        }
        return true
    }
    
    func isNotMinialLength(_ str: String?) -> Bool {
        return str != nil && str!.count < 2
    }
    
    func isValidEmail(_ str: String?) -> Bool {
        if (str == nil) {
            return false
        }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: str)
    }
    
    func isValidPhone(_ str: String?) -> Bool {
        //TODO: test!
        let FIRST_PHONE_REGEX = "^[0-9]+$"
        let SECOND_PHONE_REGEX = "^\\+(?:[0-9] ?){6,14}[0-9]$"
        let phoneTest1 = NSPredicate(format: "SELF MATCHES %@", FIRST_PHONE_REGEX)
        let phoneTest2 = NSPredicate(format: "SELF MATCHES %@", SECOND_PHONE_REGEX)
        let result = phoneTest1.evaluate(with: str) == true || phoneTest2.evaluate(with: str) == true
        return result
    }
    
    func showAlertOnSuccess() {
        let refreshAlert = UIAlertController(title: "", message: "partner_form_successfully_sent".localized, preferredStyle: UIAlertController.Style.alert)
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            refreshAlert.dismiss(animated: true)
            if let first = self.presentingViewController,
                let second = first.presentingViewController{
                  first.view.isHidden = true
                  second.dismiss(animated: true)
             }
        }))
        present(refreshAlert, animated: true, completion: nil)
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
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.scrollView.contentInset = .zero
        self.scrollView.scrollIndicatorInsets = .zero
    }
}
