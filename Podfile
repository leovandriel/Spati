source 'https://github.com/CocoaPods/Specs.git'

pod 'AFNetworking', '~> 2.2.0', inhibit_warnings: true
pod 'NWLogging', '~> 1.2.0'

target :SpatiTouchStatic do
  platform :ios
end

target :SpatiCocoaStatic do
  platform :osx 
end

target :SpatiTouchTests, :exclusive => true do
  pod 'Kiwi/XCTest'
end

target :SpatiCocoaTests, :exclusive => true do
  pod 'Kiwi/XCTest'
end
