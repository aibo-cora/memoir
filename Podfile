platform :ios, '12.0'
#Delete the following block to go back to previous version of the file
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      end
    end
  end

target 'Memoir' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Memoir
    pod 'Alamofire', '~> 5.1'
    pod 'Firebase'
    pod 'SwiftyJSON'
    pod 'GoogleAPIClientForREST'
    pod 'GoogleSignIn'
    pod 'PRTween', '~> 0.1'
end
