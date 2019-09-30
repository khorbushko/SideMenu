Pod::Spec.new do |s|

s.platform = :ios
s.ios.deployment_target = '11.0'
s.name = "HKSideMenu"
s.summary = "Simple SideMenu for iOS app"
s.requires_arc = true
s.version = "0.0.1"
s.license = 'MIT'
s.author = { "Kyryl" => "kirill.ge@gmail.com" }
s.homepage = "https://github.com/kirillgorbushko/SideMenu.git"
s.source = { :git => "https://github.com/kirillgorbushko/SideMenu.git",
                :tag => "#{s.version}" }
s.framework = "UIKit"
s.source_files = "HKSideMenu/Source/**/*.{swift}"
s.swift_version = "5.1"

end
