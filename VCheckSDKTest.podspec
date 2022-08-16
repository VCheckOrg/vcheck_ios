Pod::Spec.new do |spec|

  spec.name         = "VCheckSDKTest"
  spec.version      = "1.0.2"
  spec.summary      = "VCheck SDK for iOS: test/dev environment only"

  spec.description  = "This SDK allows to integrate VCheck core features (documents validation, face liveness checks) into iOS projects"

  spec.homepage     = "https://vycheck.com/"

  spec.license      = "MIT"
  spec.license    = { :type => "MIT", :file => "LICENSE" }

  spec.author       = { "vycheck" => "info@vycheck.com" }

  spec.platform     = :ios
  spec.platform     = :ios, "15.2"

  spec.source       = { :git => "https://github.com/VCheckOrg/vcheck_ios_sdk_test.git", :tag => "#{spec.version}" }

  spec.source_files  = "VCheckSDK/VCheckSDK/**/*.{swift}"
  
  spec.resources = ["VCheckSDK/VCheckSDK/**/*.storyboard",
                    "VCheckSDK/VCheckSDK/**/*.imageasset",
                    "VCheckSDK/VCheckSDK/**/*.strings",
                    "VCheckSDK/VCheckSDK/**/*.json"]
  
  spec.dependency "Alamofire"
  spec.dependency "lottie-ios"
  
  spec.swift_version = "5.6"

end
