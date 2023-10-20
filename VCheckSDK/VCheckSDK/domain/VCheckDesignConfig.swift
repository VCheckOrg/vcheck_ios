//
//  VCheckDesignConfig.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 19.10.2023.
//

import Foundation

public struct VCheckDesignConfig : Codable {
    
    static func fromJsonStr(rawJsonStr: String) -> VCheckDesignConfig {
        
        if let value = try? JSONDecoder().decode(VCheckDesignConfig.self, from: rawJsonStr.data(using: .utf8)!) {
            return value
        } else {
            print("VCheckSDK - warning: Non-valid JSON was passed while initializaing VCheckDesignConfig instance; trying to set VCheck default theme...")
            return try! JSONDecoder().decode(VCheckDesignConfig.self, from: defaultThemeJsonStr.data(using: .utf8)!)
        }
    }
    
    let primary : String?
    let primaryHover : String?
    let primaryActive : String?
    let primaryContent : String?
    let primaryBg : String?
    let accent : String?
    let accentHover : String?
    let accentActive : String?
    let accentContent : String?
    let accentBg : String?
    let neutral : String?
    let neutralHover : String?
    let neutralActive : String?
    let neutralContent : String?
    let success : String?
    let successHover : String?
    let successActive : String?
    let successBg : String?
    let successContent : String?
    let error : String?
    let errorHover : String?
    let errorActive : String?
    let errorBg : String?
    let errorContent : String?
    let warning : String?
    let warningHover : String?
    let warningActive : String?
    let warningBg : String?
    let warningContent : String?
    let base : String?
    let base_100 : String?
    let base_200 : String?
    let base_300 : String?
    let base_400 : String?
    let base_500 : String?
    let baseContent : String?
    let baseSecondaryContent : String?
    let disabled : String?
    let disabledContent : String?

    enum CodingKeys: String, CodingKey {

        case primary = "primary"
        case primaryHover = "primaryHover"
        case primaryActive = "primaryActive"
        case primaryContent = "primaryContent"
        case primaryBg = "primaryBg"
        case accent = "accent"
        case accentHover = "accentHover"
        case accentActive = "accentActive"
        case accentContent = "accentContent"
        case accentBg = "accentBg"
        case neutral = "neutral"
        case neutralHover = "neutralHover"
        case neutralActive = "neutralActive"
        case neutralContent = "neutralContent"
        case success = "success"
        case successHover = "successHover"
        case successActive = "successActive"
        case successBg = "successBg"
        case successContent = "successContent"
        case error = "error"
        case errorHover = "errorHover"
        case errorActive = "errorActive"
        case errorBg = "errorBg"
        case errorContent = "errorContent"
        case warning = "warning"
        case warningHover = "warningHover"
        case warningActive = "warningActive"
        case warningBg = "warningBg"
        case warningContent = "warningContent"
        case base = "base"
        case base_100 = "base_100"
        case base_200 = "base_200"
        case base_300 = "base_300"
        case base_400 = "base_400"
        case base_500 = "base_500"
        case baseContent = "baseContent"
        case baseSecondaryContent = "baseSecondaryContent"
        case disabled = "disabled"
        case disabledContent = "disabledContent"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        primary = try values.decodeIfPresent(String.self, forKey: .primary)
        primaryHover = try values.decodeIfPresent(String.self, forKey: .primaryHover)
        primaryActive = try values.decodeIfPresent(String.self, forKey: .primaryActive)
        primaryContent = try values.decodeIfPresent(String.self, forKey: .primaryContent)
        primaryBg = try values.decodeIfPresent(String.self, forKey: .primaryBg)
        accent = try values.decodeIfPresent(String.self, forKey: .accent)
        accentHover = try values.decodeIfPresent(String.self, forKey: .accentHover)
        accentActive = try values.decodeIfPresent(String.self, forKey: .accentActive)
        accentContent = try values.decodeIfPresent(String.self, forKey: .accentContent)
        accentBg = try values.decodeIfPresent(String.self, forKey: .accentBg)
        neutral = try values.decodeIfPresent(String.self, forKey: .neutral)
        neutralHover = try values.decodeIfPresent(String.self, forKey: .neutralHover)
        neutralActive = try values.decodeIfPresent(String.self, forKey: .neutralActive)
        neutralContent = try values.decodeIfPresent(String.self, forKey: .neutralContent)
        success = try values.decodeIfPresent(String.self, forKey: .success)
        successHover = try values.decodeIfPresent(String.self, forKey: .successHover)
        successActive = try values.decodeIfPresent(String.self, forKey: .successActive)
        successBg = try values.decodeIfPresent(String.self, forKey: .successBg)
        successContent = try values.decodeIfPresent(String.self, forKey: .successContent)
        error = try values.decodeIfPresent(String.self, forKey: .error)
        errorHover = try values.decodeIfPresent(String.self, forKey: .errorHover)
        errorActive = try values.decodeIfPresent(String.self, forKey: .errorActive)
        errorBg = try values.decodeIfPresent(String.self, forKey: .errorBg)
        errorContent = try values.decodeIfPresent(String.self, forKey: .errorContent)
        warning = try values.decodeIfPresent(String.self, forKey: .warning)
        warningHover = try values.decodeIfPresent(String.self, forKey: .warningHover)
        warningActive = try values.decodeIfPresent(String.self, forKey: .warningActive)
        warningBg = try values.decodeIfPresent(String.self, forKey: .warningBg)
        warningContent = try values.decodeIfPresent(String.self, forKey: .warningContent)
        base = try values.decodeIfPresent(String.self, forKey: .base)
        base_100 = try values.decodeIfPresent(String.self, forKey: .base_100)
        base_200 = try values.decodeIfPresent(String.self, forKey: .base_200)
        base_300 = try values.decodeIfPresent(String.self, forKey: .base_300)
        base_400 = try values.decodeIfPresent(String.self, forKey: .base_400)
        base_500 = try values.decodeIfPresent(String.self, forKey: .base_500)
        baseContent = try values.decodeIfPresent(String.self, forKey: .baseContent)
        baseSecondaryContent = try values.decodeIfPresent(String.self, forKey: .baseSecondaryContent)
        disabled = try values.decodeIfPresent(String.self, forKey: .disabled)
        disabledContent = try values.decodeIfPresent(String.self, forKey: .disabledContent)
    }
    
    static let defaultThemeJsonStr: String =
     """
     {
       "primary": "#2E75FF",
       "primaryHover": "#2E96FF",
       "primaryActive": "#3361EC",
       "primaryContent": "#FFFFFF",
       "primaryBg": "#5D6884",
       "accent": "#6096FF",
       "accentHover": "#6ABFFF",
       "accentActive": "#4F79F7",
       "accentContent": "#FFFFFF",
       "accentBg": "#32404A",
       "neutral": "#FFFFFF",
       "neutralHover": "rgba(255, 255, 255, 0.4)",
       "neutralActive": "rgba(255, 255, 255, 0.1)",
       "neutralContent": "#000000",

       "success": "#6CFB93",
       "successHover": "#C8FDD2",
       "successActive": "#00DF53",
       "successBg": "#3A4B3F",
       "successContent": "#3B3B3B",
       "error": "#F47368",
       "errorHover": "#FF877C",
       "errorActive": "#DE473A",
       "errorBg": "#4B2A24",
       "errorContent": "#3B3B3B",
       "warning": "#FFB482",
       "warningHover": "#FFBF94",
       "warningActive": "#D3834E",
       "warningBg": "#3F3229",
       "warningContent": "#3B3B3B",

       "base": "#2A2A2A",
       "base_100": "#3C3C3C",
       "base_200": "#555555",
       "base_300": "#6A6A6A",
       "base_400": "#7F7F7F",
       "base_500": "#949494",
       "baseContent": "#FFFFFF",
       "baseSecondaryContent": "#D8D8D8",
       "disabled": "#AAAAAA",
       "disabledContent": "#6A6A6A"
     }
     """
}
