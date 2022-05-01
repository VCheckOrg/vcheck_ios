//
//  RoundedView.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 29.04.2022.
//

import UIKit

@IBDesignable public class RoundedView: UIView {

    @IBInspectable var borderColor: UIColor = UIColor.white {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

    @IBInspectable var borderWidth: CGFloat = 2.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat = 12.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

}
