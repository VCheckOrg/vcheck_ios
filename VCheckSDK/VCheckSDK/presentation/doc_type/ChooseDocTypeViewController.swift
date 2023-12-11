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
        
    @IBOutlet weak var sectionDefaultInnerPassport: SmallRoundedView!
    @IBOutlet weak var sectionForeignPasspot: SmallRoundedView!
    @IBOutlet weak var sectionIDCard: SmallRoundedView!

    @IBOutlet weak var foreignCardTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var idCardTopConstraint: NSLayoutConstraint!
    
    @IBAction func backToCountriesAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
        navigationController?.popViewController(animated: true) //?
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.viewModel.getAvailableDocTypes()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            self.resolveCardsTopConstraints()
        }
   
        self.viewModel.getAvailableDocTypes()
    }
    
    private func resolveCardsTopConstraints() {
        let l : [DocType]? = self.viewModel.docTypeDataArr.map { DocType.docCategoryIdxToType(categoryIdx: $0.category!) }
        if let categoriesList = l {
            if (!categoriesList.contains(DocType.INNER_PASSPORT_OR_COMMON)) {
                if (categoriesList.contains(DocType.FOREIGN_PASSPORT) && categoriesList.contains(DocType.ID_CARD)) {
                    self.foreignCardTopConstraint.constant = 28.0
                    self.idCardTopConstraint.constant = 118.0
                }
                if (!categoriesList.contains(DocType.FOREIGN_PASSPORT) && categoriesList.contains(DocType.ID_CARD)) {
                    self.idCardTopConstraint.constant = 28.0
                }
            }
            if (!categoriesList.contains(DocType.FOREIGN_PASSPORT)) {
                if (categoriesList.contains(DocType.INNER_PASSPORT_OR_COMMON) && categoriesList.contains(DocType.ID_CARD)) {
                    self.idCardTopConstraint.constant = 118.0
                }
                if (!categoriesList.contains(DocType.INNER_PASSPORT_OR_COMMON) && categoriesList.contains(DocType.ID_CARD)) {
                    self.idCardTopConstraint.constant = 28.0
                }
            }
        }
        
    }
    
    @objc func navigateForwardOnInnerPassportSelected(_ sender:UITapGestureRecognizer) {
        selectDocTypeDataAndNavigateForward(data: viewModel.docTypeDataArr.first(where: { $0.category == 0 })!)
    }
    
    @objc func navigateForwardOnForeginPassportSelected(_ sender:UITapGestureRecognizer) {
        selectDocTypeDataAndNavigateForward(data: viewModel.docTypeDataArr.first(where: { $0.category == 1 })!)
    }
    
    @objc func navigateForwardOnIDCardSelected(_ sender:UITapGestureRecognizer) {
        selectDocTypeDataAndNavigateForward(data: viewModel.docTypeDataArr.first(where: { $0.category == 2 })!)
    }
    
    private func selectDocTypeDataAndNavigateForward(data: DocTypeData) {
        VCheckSDKLocalDatasource.shared.setSelectedDocTypeWithData(data: data)
        performSegue(withIdentifier: "ChooseDocTypeToPhotoInfo", sender: self)
    }
}
