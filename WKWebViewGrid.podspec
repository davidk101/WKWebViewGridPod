#
# Be sure to run `pod lib lint WKWebViewGrid.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WKWebViewGrid'
  s.version          = '0.1.0'
  s.summary          = 'Add Grid functionality to WKWebViews.'
  s.swift_versions = '5.1'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
'Add Grid functionality to WKWebViews with Touch Bar capabilities to support in-app browsing.'
                       DESC

  s.homepage         = 'https://github.com/davidk101/WKWebViewGrid'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'davidk101' => 'david.dn.kumar@gmail.com' }
  s.source           = { :git => 'https://github.com/davidk101/WKWebViewGrid.git', :tag => s.version.to_s }

  s.platform = :osx
  s.osx.deployment_target = "10.12.2"

  s.source_files = 'Source/**/*.swift'

  # s.resource_bundles = {
  #   'WKWebViewGrid' => ['WKWebViewGrid/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'Cocoa'
  # s.dependency 'AFNetworking', '~> 2.3'
end
