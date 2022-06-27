# ARCore SDK for iOS

This pod contains the ARCore SDK for iOS.

# Getting Started

*   *Cloud Anchors Quickstart*:
    https://developers.google.com/ar/develop/ios/cloud-anchors/quickstart
*   *Augmented Faces Quickstart*:
    https://developers.google.com/ar/develop/ios/augmented-faces/quickstart
*   *Reference*: https://developers.google.com/ar/reference/ios
*   *Code samples*: Sample apps are available for download at
    https://github.com/google-ar/arcore-ios-sdk/tree/master/Examples. Be sure to
    follow any instructions in README files.

# Installation

To integrate ARCore SDK for iOS into your Xcode project using CocoaPods, specify
it in your `Podfile`:

```
target 'YOUR_APPLICATION_TARGET_NAME_HERE'
platform :ios, '11.0'
pod 'ARCore/SUBSPEC_NAME_HERE' ~> VERSION_HERE
```

Lower deployment targets (down to 10.0) will build, but the Cloud Anchors API
won't be functional at runtime unless iOS version >= 11.0. Also, you must be
building with at least version 13.0 of the iOS SDK.

Then, run the following command:

```
$ pod install
```

Before you can start using the Cloud Anchors API, you will need to register an
API key in the
[Google Developer Console](https://console.developers.google.com/) for the
ARCore Cloud Anchor service.

# License and Terms of Service

By using the ARCore SDK for iOS you accept Google's Terms of Service and
Policies (https://developers.google.com/terms/).
