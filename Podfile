source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'
use_frameworks!

def app_pods
  pod 'DTTJailbreakDetection', '~> 0.4.0'
  pod 'GRMustache', '~> 7.3.2'
  pod 'GRMustache.swift', :git => 'https://github.com/ZipID/GRMustache.swift.git', :tag => 'master'
  pod 'MagicalRecord', :git => 'https://github.com/magicalpanda/MagicalRecord.git', :tag => 'v2.3.3'
  pod 'AFNetworking', '~> 3.1.0'
  pod 'AFNetworkActivityLogger', :git => 'https://github.com/AFNetworking/AFNetworkActivityLogger.git', :branch => '3_0_0'
  pod 'PromiseKit/CorePromise', '~> 3.5'
  pod 'DateTools', '~> 1.7.0'
  pod 'Fabric', '~> 1.6.7'
  pod 'Crashlytics', '~> 3.7.1'
  pod 'Analytics', '~> 3.2.4'
  pod 'ISHPermissionKit', :git => 'https://github.com/ZipID/ISHPermissionKit.git', :branch => 'master'
end

target 'ZipID' do
  app_pods
end

target 'ZipID Enterprise' do
  app_pods
end

target 'ZipIDTests' do
  pod 'AFNetworking', '~> 3.1.0'
  pod 'MagicalRecord', :git => 'https://github.com/magicalpanda/MagicalRecord.git', :tag => 'v2.3.3'
  pod 'OHHTTPStubs', '~> 5.1.0'
end

target 'KIFUITests' do
  pod 'AFNetworking', '~> 3.1.0'
  pod 'MagicalRecord', :git => 'https://github.com/magicalpanda/MagicalRecord.git', :tag => 'v2.3.3'
  pod 'OHHTTPStubs', '~> 5.1.0'
  pod 'KIF', '~> 3.5.1'
  pod 'Analytics', '~> 3.2.4'
  pod 'GCDWebServer', '~> 3.0'
end

target 'ZipIDUITests' do
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '2.3'
    end
  end
end
