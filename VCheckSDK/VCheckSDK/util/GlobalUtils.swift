//
//  GlobalUtils.swift
//  VcheckFramework
//
//  Created by Kirill Kaun on 21.06.2022.
//

import Foundation
import UIKit
import SwiftUI

public final class GlobalUtils {
    
    public static func getVCheckHomeVC() -> UIViewController {

        let storyboard = UIStoryboard.init(name: "VCheckFlow", bundle: Bundle(for: self))
        let homeVC = storyboard.instantiateInitialViewController()
        return homeVC!
    }
}

extension UIImage {
  convenience init?(named: String) {
      self.init(named: named, in: InternalConstants.bundle, compatibleWith: nil)
  }
}

extension Text {
init(textKey: LocalizedStringKey) {
    self.init(textKey, bundle: InternalConstants.bundle)
  }
}

internal struct InternalConstants {
    private class EmptyClass {}
    static let bundle = Bundle(for: InternalConstants.EmptyClass.self)
}

extension String {
    public var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: InternalConstants.bundle, value: "", comment: "")
    }
}
