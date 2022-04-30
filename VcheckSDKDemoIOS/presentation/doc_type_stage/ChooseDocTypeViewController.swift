//
//  ChooseDocTypeViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 30.04.2022.
//

import Foundation
import UIKit

class ChooseDocTypeViewController : UIViewController {
    
    private let viewModel = ChooseDocTypeViewModel()
    
    @IBOutlet weak var backArrow: UIImageView!
    
    @IBOutlet weak var sectionDefaultInnerPassport: RoundedView!
    
    @IBOutlet weak var sectionForeignPasspot: RoundedView!
    
    @IBOutlet weak var sectionIDCard: RoundedView!
    
    
    override func viewDidLoad() {
        
        self.sectionDefaultInnerPassport.isHidden = true
        self.sectionForeignPasspot.isHidden = true
        self.sectionIDCard.isHidden = true
        
        self.viewModel.retrievedDocTypes = {
            self.viewModel.docTypeDataArr.forEach {
                switch(DocType.docCategoryIdxToType(categoryIdx: $0.category!)) {
                case DocType.INNER_PASSPORT_OR_COMMON:
                    self.sectionDefaultInnerPassport.isHidden = false
                    self.sectionDefaultInnerPassport.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                               action: #selector (self.navigateForwardOnInnerPassportSelected(_:))))
                case DocType.FOREIGN_PASSPORT:
                    self.sectionForeignPasspot.isHidden = false
                    self.sectionForeignPasspot.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                               action: #selector (self.navigateForwardOnForeginPassportSelected(_:))))
                case DocType.ID_CARD:
                    self.sectionIDCard.isHidden = false
                    self.sectionIDCard.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                action: #selector (self.navigateForwardOnIDCardSelected(_:))))
                    
                }
            }
        }
        
        self.viewModel.getAvailableDocTypes()
    }
    
    @objc func navigateForwardOnInnerPassportSelected(_ sender:UITapGestureRecognizer){
        KeychainHelper.shared.setSelectedDocTypeWithData(data:
                        viewModel.docTypeDataArr.first(where: { $0.category == 0 })!)
        performSegue(withIdentifier: "ChooseDocTypeToPhotoInfo", sender: self)
    }
    
    @objc func navigateForwardOnForeginPassportSelected(_ sender:UITapGestureRecognizer){
        KeychainHelper.shared.setSelectedDocTypeWithData(data:
                        viewModel.docTypeDataArr.first(where: { $0.category == 1 })!)
        performSegue(withIdentifier: "ChooseDocTypeToPhotoInfo", sender: self)
    }
    
    @objc func navigateForwardOnIDCardSelected(_ sender:UITapGestureRecognizer){
        KeychainHelper.shared.setSelectedDocTypeWithData(data:
                        viewModel.docTypeDataArr.first(where: { $0.category == 2 })!)
        performSegue(withIdentifier: "ChooseDocTypeToPhotoInfo", sender: self)
    }
}
