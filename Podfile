platform :ios, '13.0'

target 'Memoir' do
  use_frameworks!

  # Pods for Memoir
  pod 'Alamofire', '~> 5.9'
  pod 'SwiftyJSON'
  pod 'GoogleAPIClientForREST'
  pod 'PRTween', '~> 0.1'

  # Old Firebase umbrella (kept for minimal change)
  pod 'Firebase'

  # Pin GoogleSignIn to the last version that still has GIDSignInDelegate
  pod 'GoogleSignIn', '~> 5.0.2'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      config.build_settings['ENABLE_BITCODE'] = 'NO'

      if config.build_settings['SDKROOT'] == 'iphonesimulator'
        config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
      end
    end
  end
end
