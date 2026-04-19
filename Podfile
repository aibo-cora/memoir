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
      # Set deployment target consistently
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      
      # Disable Bitcode (recommended for most modern pods)
      config.build_settings['ENABLE_BITCODE'] = 'NO'

      # Fix for GoogleSignIn and other pods: Exclude arm64 for simulator
      # This prevents the "built for iOS, but linking for iOS-simulator" error
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
    end
  end
end
