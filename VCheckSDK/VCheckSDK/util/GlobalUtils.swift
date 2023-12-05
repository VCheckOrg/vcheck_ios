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

internal struct InternalConstants {
    private class EmptyClass {}
    static let bundle = Bundle(for: InternalConstants.EmptyClass.self)
}

var bundleKey: UInt8 = 0

class AnyLanguageBundle: Bundle {

    override func localizedString(forKey key: String,
                              value: String?,
                              table tableName: String?) -> String {

        guard let path = objc_getAssociatedObject(self, &bundleKey) as? String,
            let bundle = Bundle(path: path) else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {

    class func setLanguage(_ language: String) {
        defer {
            object_setClass(InternalConstants.bundle, AnyLanguageBundle.self)
        }
        objc_setAssociatedObject(InternalConstants.bundle, &bundleKey,
                                 InternalConstants.bundle.path(forResource: language, ofType: "lproj"),
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

extension UIApplication {

  static var topWindow: UIWindow {
    if #available(iOS 15.0, *) {
      let scenes = UIApplication.shared.connectedScenes
      let windowScene = scenes.first as? UIWindowScene
      return windowScene!.windows.first!
    } else {
        return UIApplication.shared.windows.filter { $0.isKeyWindow }.first!
    }
  }
}

extension UIDevice {
    static var isSimulator: Bool = {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }()
}

enum VCheckError: Error {
    case initError(String)
}
