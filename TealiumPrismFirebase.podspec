Pod::Spec.new do |s|
    s.name             = 'TealiumPrismFirebase'
    s.module_name      = "TealiumPrismFirebase"
    s.version          = '1.0.0'
    s.summary          = 'Tealium Prism Firebase Dispatcher'
    
    s.description      = <<-DESC
                         Firebase Analytics dispatcher for Tealium Prism SDK.
                         DESC
    
    s.homepage         = 'https://github.com/Tealium/tealium-prism-ios-firebase-dispatcher'
    s.license          = { :type => "Commercial", :file => "LICENSE" }
    s.authors          = { "Tealium Inc." => "dev@tealium.com" }
    s.source           = { :git => "https://github.com/Tealium/tealium-prism-ios-firebase-dispatcher.git", :tag => "#{s.version}" }
    s.social_media_url = "https://twitter.com/tealium"
    
    s.ios.deployment_target = '15.0'
    s.osx.deployment_target = "10.15"
    s.tvos.deployment_target = "15.0"
    
    s.swift_version = '5.5'
    
    s.source_files = "Sources/TealiumPrismFirebase/**/*.{swift,h,m}"
    
    # IMPORTANT: Use '>= 0.5.0' instead of '~> 0.5.0' to allow local development
    # With '~> 0.5.0', CocoaPods tries to resolve version from git before checking local pods
    # With '>= 0.5.0', CocoaPods can use local pods from Podfile
    s.dependency 'tealium-prism/Core', '>= 0.5.0'
    s.dependency 'Firebase/Analytics', '~> 12.0'
  end