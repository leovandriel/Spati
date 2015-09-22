Pod::Spec.new do |s|
  s.name          = 'Spati'
  s.version       = '0.2.2'
  s.summary       = 'A caching layer for Objective-C.'
  s.homepage      = 'https://github.com/leonardvandriel/Spati'
  s.license       = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author        = { 'Leonard van Driel' => 'leonardvandriel@gmail.com' }

  s.platform      = :ios
  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'
  s.requires_arc  = true
  s.source        = { :git => 'https://github.com/leonardvandriel/Spati.git', :tag => s.version.to_s }
  s.source_files  = 'Classes/**/*.{h,m,c}'
  s.osx.exclude_files = 'Classes/**/{UI,WDSImageNamedDisk}*.{h,m}'
  s.framework     = 'UIKit'
  s.dependency 'AFNetworking', '~> 2.0'
  s.dependency 'NWLogging', '~> 1.2.0'
  s.prefix_header_contents = '#define NWL_LIB Spati'
end
