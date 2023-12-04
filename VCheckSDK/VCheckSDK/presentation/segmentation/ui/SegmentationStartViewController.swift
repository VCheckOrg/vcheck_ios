//
//  SegmentationStartViewController.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 05.08.2022.
//

import Foundation
import UIKit

class SegmentationStartViewController: UIViewController {
    
    @IBOutlet weak var imgDocBack1: UIImageView!
    @IBOutlet weak var imgDocBack2: UIImageView!
    @IBOutlet weak var imgDocMid: UIImageView!
    @IBOutlet weak var imgDocFront: UIImageView!
    
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
                
        if let category = VCheckSDKLocalDatasource.shared.getSelectedDocTypeWithData()?.category {
            switch (DocType.docCategoryIdxToType(categoryIdx: category)) {
                case DocType.ID_CARD:
                    //skip 1st z-layer image setting for id card doc type
                    self.imgDocBack1.isHidden = true
                    self.imgDocBack2.image = UIImage.init(named: "il_doc_id_card_back_2")
                    self.imgDocMid.image = UIImage.init(named: "il_doc_id_card_mid")
                    self.imgDocFront.image = UIImage.init(named: "il_doc_id_card_avatar")
                    self.tvInstrTtile.text = "segmentation_instr_id_card_title".localized
                    self.tvInstDescription.text = "segmentation_instr_id_card_descr".localized
                case DocType.FOREIGN_PASSPORT:
                    self.imgDocBack1.isHidden = false
                    self.imgDocBack1.image = UIImage.init(named: "il_doc_int_back_1")
                    self.imgDocBack2.image = UIImage.init(named: "il_doc_int_back_2")
                    self.imgDocMid.image = UIImage.init(named: "il_doc_int_mid")
                    self.imgDocFront.image = UIImage.init(named: "il_doc_int_avatar")
                    self.tvInstrTtile.text = "segmentation_instr_foreign_passport_title".localized
                    self.tvInstDescription.text = "segmentation_instr_foreign_passport_descr".localized
                default:
                    self.imgDocBack1.isHidden = false
                    self.imgDocBack1.image = UIImage.init(named: "il_doc_ukr_back_1")
                    self.imgDocBack2.image = UIImage.init(named: "il_doc_ukr_back_2")
                    self.imgDocMid.image = UIImage.init(named: "il_doc_ukr_mid")
                    self.imgDocFront.image = UIImage.init(named: "il_doc_ukr_avatar")
                    self.tvInstrTtile.text = "segmentation_instr_inner_passport_title".localized
                    self.tvInstDescription.text = "segmentation_instr_inner_passport_descr".localized
            }
            
            if let primaryColor = VCheckSDK.shared.designConfig!.primary {
                self.imgDocFront.image = self.imgDocFront.image!.withTintColor(primaryColor.hexToUIColor())
            }
            if let primaryTextColor = VCheckSDK.shared.designConfig!.primaryTextColorHex {
                self.imgDocMid.image = self.imgDocMid.image!.withTintColor(primaryTextColor.hexToUIColor())
            }
            if let bgColor = VCheckSDK.shared.designConfig!.primaryBg {
                self.imgDocBack1.image = self.imgDocBack1.image!.withTintColor(bgColor.hexToUIColor())
            }
            if let bgSecondaryColor = VCheckSDK.shared.designConfig!.backgroundSecondaryColorHex {
                if (DocType.docCategoryIdxToType(categoryIdx: category) != DocType.ID_CARD) {
                    self.imgDocBack2.image = self.imgDocBack2.image!.withTintColor(bgSecondaryColor.hexToUIColor())
                }
            }
            
        } else {
            print("VCheck SDK - error: no Selected Doc Type With Data provided for seg start view controller")
        }
    }
    
    
    @objc func startSegSession(_ sender: UITapGestureRecognizer) {
       performSegue(withIdentifier: "SegStartToSession", sender: self)
    }
    
}
