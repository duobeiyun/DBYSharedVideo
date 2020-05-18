#
#  Be sure to run `pod spec lint DBYSharedVideo.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "DBYSharedVideo"
  s.version      = "2.1.1"
  s.summary      = "新版大班"
  s.description  = <<-DESC
DBYSharedVideo主要是封装了直播和回放的界面，方便开发者快速对接自己的产品。主要特点是快速集成，不支持界面定制。
                   DESC

  s.homepage     = "http://zhonglaoban/DBYSharedVideo"
  s.license      = "MIT"
  s.author       = { "zhongfan" => "fan.zhong@duobei.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "http://zhonglaoban/DBYSharedVideo.git", :tag => "#{s.version}" }
  s.source_files  = "**/*.{h,m,swift}"
  s.resources = "**/*.xib", "Assets.xcassets"
  s.dependency "DBYSDK_dylib"
  s.dependency "SDWebImage"
  
  s.info_plist = {
    "CFBundleIdentifier" => "com.duobei.DBYSharedVideo",
    "CFBundleVersion" => "1"
  }
  s.pod_target_xcconfig = {
    "PRODUCT_BUNDLE_IDENTIFIER" => "com.duobei.DBYSharedVideo",
    "GCC_PREPROCESSOR_DEFINITIONS" => "$(inherited) COCOAPODS=1 IOS=1"
  }

end
