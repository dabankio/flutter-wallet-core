#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_wallet_core.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_wallet_core'
  s.version          = '0.0.1'
  s.summary          = 'flutter sdk for wallet-core.'
  s.description      = <<-DESC
  flutter sdk for wallet-core.
                       DESC
  s.homepage         = 'https://github.com/dabankio/flutter-wallet-core'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Dabank' => 'stamen0630@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'
  s.vendored_frameworks = 'Classes/wallet.framework'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
