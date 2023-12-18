# VCheck SDK for iOS

[VCheck](https://vycheck.com/) is online remote verification service for fast and secure customer access to your services.

## Features

- Document validity: Country and document type identification. Checks for forgery and interference (glare, covers, third-party objects)
- Document data recognition: The data of the loaded document is automatically parsed
- Liveliness check: Determining that a real person is being verified
- Face matching: Validate that the document owner is the user being verified
- Easy integration to your service's iOS app out-of-the-box

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
            .languageCode(langCode: langCode)
            .environment(env: VCheckEnvironment.DEV)
            .showPartnerLogo(show: false)
            .showCloseSDKButton(show: true)
            .designConfig(config: yourDesignConfig)
            .partnerEndCallback(callback: {
                self.onSDKFlowFinished()
            })
            .onVerificationExpired(callback: {
                self.onVerificationExpired()
            })
            .start(partnerAppRW: (getOwnSceneDelegate()?.window!)!,
                    partnerAppVC: self,
                    replaceRootVC: true)
```

#### Explication for required properties

| Property | Type | Description |
| ----------- | ----------- | ----------- |
| verificationToken | String | Valid token of recently created VCheck Verification |
| verificationType | VerificationSchemeType | Verification scheme type |
| languageCode | String | 2-letter language code (Ex.: "en" ; implementation's default is "en") |
| environment | VCheckEnvironment | VCheck service environment (dev/partner) |
| partnerEndCallback | Function | Callback function which triggers on verification process and SDK flow finish |
| onVerificationExpired | Function | Callback function which triggers when current verification goes to expired state |


#### Optional properties for verification session's logic and UI customization

| Property | Type | Description |
| ----------- | ----------- | ----------- |
| designConfig | String? | JSON string with specific fixed set of color properties, which can be obtained as a VCheck portal user |
| showCloseSDKButton | bool? | Should 'Return to Partner' button be shown |
| showPartnerLogo | bool? | Should VCheck logo be shown |

