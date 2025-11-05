# Uncomment the next line to define a global platform for your project
platform :ios, '17.0'

target 'sandtetris' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for sandtetris
  pod 'Google-Mobile-Ads-SDK'

  target 'sandtetrisTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'sandtetrisUITests' do
    # Pods for testing
  end

end

# Xcode Cloud対応: ビルド設定を明示的に指定
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
      config.build_settings['CODE_SIGN_IDENTITY'] = ''

      # Xcode Cloudのrealpath問題を回避
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
    end
  end

  # CocoaPodsリソーススクリプトの問題を修正
  installer.pods_project.targets.each do |target|
    target.build_phases.each do |build_phase|
      if build_phase.display_name == '[CP] Copy Pods Resources'
        build_phase.shell_script.gsub!(/realpath -m/, 'realpath')
      end
    end
  end
end
