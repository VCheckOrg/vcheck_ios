Pod::Spec.new do |spec|

  spec.name         = "VCheckSDK"
  spec.version      = "1.0.27"
  spec.summary      = "VCheck SDK for iOS"

  spec.description  = "This SDK allows to integrate VCheck core features (documents validation, face liveness checks) into iOS projects"

  spec.homepage     = "https://github.com/VCheckOrg/vcheck_ios"

  spec.license      = "MIT"
  spec.license    = { :type => "MIT", :file => "LICENSE" }

  spec.author       = { "vycheck" => "info@vycheck.com" }

  spec.platform     = :ios
  spec.platform     = :ios, "14.0"

  spec.source       = { :git => "https://github.com/VCheckOrg/vcheck_ios.git", :tag => "#{spec.version}" }

  spec.source_files  = "VCheckSDK/VCheckSDK/**/*.{swift}"
  
  spec.resources = ["VCheckSDK/VCheckSDK/**/*.storyboard",
                    "VCheckSDK/VCheckSDK/**/*.xcassets",
                    "VCheckSDK/VCheckSDK/**/*.strings",
                    "VCheckSDK/VCheckSDK/**/*.json"]
  
  spec.dependency "Alamofire"
  spec.dependency "lottie-ios"
  
  spec.swift_version = "5.6"

end
