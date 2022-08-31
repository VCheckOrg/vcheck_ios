# VCheck SDK for iOS

[VCheck](https://vycheck.com/) is online remote verification service for fast and secure customer access to your services.

## Features

- Document validity: Country and document type identification. Checks for forgery and interference (glare, covers, third-party objects)
- Document data recognition: The data of the loaded document is automatically parsed
- Liveliness check: Determining that a real person is being verified
- Face matching: Validate that the document owner is the user being verified
- Easy integration to your service's Flutter app out-of-the-box

## How to use
#### Installing via CocoaPods

```
pod 'VCheckSDK'
```

#### Start SDK flow

```
import VCheckSDK

//...
VCheckSDK.shared
            .verificationToken(token: token)
            .verificationType(type: verifType)
            .languageCode(langCode: self.langCode)
            .environment(env: VCheckEnvironment.DEV)
            .showPartnerLogo(show: false)
            .showCloseSDKButton(show: true)
            .partnerEndCallback(callback: {
                self.onSDKFlowFinished()
            })
            .colorBackgroundSecondary(colorHex: self.backSecondaryColorHex)
            .colorBackgroundPrimary(colorHex: self.backPrimaryColorHex)
            .colorBackgroundTertiary(colorHex: self.backTertiaryColorHex)
            .colorBorders(colorHex: self.bordersColorHex)
            .colorTextPrimary(colorHex: self.primaryTextColorHex)
            .colorTextSecondary(colorHex: self.secondaryTextColorHex)
            .colorActionButtons(colorHex: self.primaryButtonColorHex)
            .colorIcons(colorHex: self.iconsColorHex)
            .start(partnerAppRW: (getOwnSceneDelegate()?.window!)!,
                    partnerAppVC: self,
                    replaceRootVC: true)
```
