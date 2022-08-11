//
//  SegmentationStartViewController.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 05.08.2022.
//

import Foundation
import UIKit

class SegmentationStartViewController: UIViewController {
    
    
    @IBOutlet weak var imgDocumentType: UIImageView!
    
    @IBOutlet weak var tvInstrTtile: UILabel!
    @IBOutlet weak var tvInstDescription: UILabel!
    
    @IBOutlet weak var btnContinue: UIButton!
    
    @IBAction func actionBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        
        btnContinue.setTitle("seg_make_photo".localized, for: .normal)
        
        btnContinue.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector (self.startSegSession(_:))))
        
        switch (DocType.docCategoryIdxToType(categoryIdx:
                    (VCheckSDKLocalDatasource.shared.getSelectedDocTypeWithData()?.category!)!)) {
            case DocType.ID_CARD:
                imgDocumentType.image = UIImage.init(named: "img_id_card_large")
                tvInstrTtile.text = "segmentation_instr_id_card_title".localized
                tvInstDescription.text = "segmentation_instr_id_card_descr".localized
            case DocType.FOREIGN_PASSPORT:
                imgDocumentType.image = UIImage.init(named: "img_internl_passport_large")
                tvInstrTtile.text = "segmentation_instr_foreign_passport_title".localized
                tvInstDescription.text = "segmentation_instr_foreign_passport_descr".localized
            default:
                imgDocumentType.image = UIImage.init(named: "img_ua_inner_passport_large")
                tvInstrTtile.text = "segmentation_instr_inner_passport_title".localized
                tvInstDescription.text = "segmentation_instr_inner_passport_descr".localized
        }
    }
    
    
    @objc func startSegSession(_ sender: UITapGestureRecognizer) {
       performSegue(withIdentifier: "SegStartToSession", sender: self)
    }
    
}
