//
//  ThemeClasses.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 22.08.2022.
//

import Foundation
import UIKit

@IBDesignable public class PrimaryTextView: UILabel {
}

@IBDesignable public class SecondaryTextView: UILabel {
}

@IBDesignable public class BackgroundView: UIView {
}

@IBDesignable public class SmallRoundedView: VCheckSDKRoundedView {
}

@IBDesignable public class FlagView: UITextView {
}

@IBDesignable public class VCheckSDKRoundedView: UIView {

    @objc dynamic var borderColor: UIColor = UIColor.white {
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

@IBDesignable public class CustomizableIconView: UIImageView {
}

@IBDesignable public class NonCustomizableIconView: UIImageView {
}

@IBDesignable public class CustomizableTableView: UITableView {
}

@IBDesignable public class CustomBackgroundTextView: UITextView {
}
