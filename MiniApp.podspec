#
# Be sure to run `pod lib lint MiniApp.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MiniApp'
  s.version          = '2.0.0'
  s.authors      = "Rakuten Ecosystem Mobile"
  s.summary      = "Rakuten's Mini App SDK"
  s.homepage     = "https://github.com/rakutentech/ios-miniapp"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.source       = { :git => "https://github.com/rakutentech/ios-miniapp.git", :tag => 'v' + s.version.to_s }

  s.ios.deployment_target = '11.0'
  
  s.source_files = 'MiniApp/Classes/**/*.swift'
  s.resources = ["MiniApp/**/*.{xcassets,js,pdf,xib}",
                "MiniApp/Classes/Resources/Certificates.p12",
                "MiniApp/Classes/Resources/miniapp-server.der"]
  s.resource_bundle = {"Localization" => ["MiniApp/*.lproj/*.strings"]}
  s.dependency 'Telegraph'

  s.dependency 'RSDKUtils', '>= 1.1.0'
  s.dependency 'ZIPFoundation'

end
