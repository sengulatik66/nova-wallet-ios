platform :ios, '11.0'

abstract_target 'fearlessAll' do
  use_frameworks!

  pod 'FearlessUtils', :git => 'https://github.com/soramitsu/fearless-utils-iOS.git', :commit => 'df483e1002750180d0c7a7144130d0208e277bbd'
  pod 'SwiftLint'
  pod 'R.swift', :inhibit_warnings => true
  pod 'FireMock', :inhibit_warnings => true
  pod 'SoraKeystore'
  pod 'SoraUI'
  pod 'RobinHood'
  pod 'CommonWallet/Core', :git => 'https://github.com/soramitsu/Capital-iOS.git', :commit => '7ab41c8a12281b25b0c9b9d621de1a9713b8a075'
  pod 'SoraFoundation', '~> 0.8.0'
  pod 'SwiftyBeaver'
  pod 'Starscream', :git => 'https://github.com/ERussel/Starscream.git', :branch => 'feature/without-origin'
  pod 'ReachabilitySwift'
  pod 'SwiftGifOrigin', '~> 1.7.0'

  target 'fearlessTests' do
    inherit! :search_paths

    pod 'Cuckoo'
    pod 'FearlessUtils', :git => 'https://github.com/soramitsu/fearless-utils-iOS.git', :commit => 'df483e1002750180d0c7a7144130d0208e277bbd'
    pod 'SoraFoundation', '~> 0.8.0'
    pod 'FireMock'
    pod 'SoraKeystore'
    pod 'RobinHood'
    pod 'CommonWallet/Core', :git => 'https://github.com/soramitsu/Capital-iOS.git', :commit => '7ab41c8a12281b25b0c9b9d621de1a9713b8a075'

  end

  target 'fearlessIntegrationTests'

  target 'fearless'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
