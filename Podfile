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

  # CocoaPodsリソーススクリプトの問題を完全に修正
  # Xcode Cloudのrealpathコマンドは-mオプションをサポートしていない
  installer.pods_project.targets.each do |target|
    target.build_phases.each do |build_phase|
      if build_phase.is_a?(Xcodeproj::Project::Object::PBXShellScriptBuildPhase) &&
         build_phase.name&.include?('[CP] Copy Pods Resources')

        # スクリプトを完全に書き換え
        build_phase.shell_script = <<-SCRIPT.strip_heredoc
          #!/bin/sh
          set -e
          set -u
          set -o pipefail

          # Xcode Cloud対応: realpath -mではなくrealpathを使用
          if [ -z ${UNLOCALIZED_RESOURCES_FOLDER_PATH+x} ]; then
            RESOURCES_TO_COPY="${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt"
            if [ -e "$RESOURCES_TO_COPY" ] && [ -r "$RESOURCES_TO_COPY" ]; then
              cat "$RESOURCES_TO_COPY" | while read source; do
                case $source in
                  *.storyboard)
                    echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!TARGETED_DEVICE_FAMILY:-1,2} --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$source\" .storyboard`.storyboardc $source --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}"
                    ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!TARGETED_DEVICE_FAMILY:-1,2} --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$source\" .storyboard`.storyboardc" "$source" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
                    ;;
                  *.xib)
                    echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!TARGETED_DEVICE_FAMILY:-1,2} --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$source\" .xib`.nib $source --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}"
                    ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!TARGETED_DEVICE_FAMILY:-1,2} --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$source\" .xib`.nib" "$source" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
                    ;;
                  *.framework)
                    echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
                    mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
                    echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" $source ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
                    rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" "$source" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
                    ;;
                  *.xcdatamodel)
                    echo "xcrun momc \"$source\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$source\"`.mom\""
                    xcrun momc "$source" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$source\" .xcdatamodel`.mom"
                    ;;
                  *.xcdatamodeld)
                    echo "xcrun momc \"$source\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$source\" .xcdatamodeld`.momd\""
                    xcrun momc "$source" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$source\" .xcdatamodeld`.momd"
                    ;;
                  *.xcmappingmodel)
                    echo "xcrun mapc \"$source\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$source\" .xcmappingmodel`.cdm\""
                    xcrun mapc "$source" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$source\" .xcmappingmodel`.cdm"
                    ;;
                  *.xcassets)
                    ABSOLUTE_XCASSET_FILE="$source"
                    XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
                    ;;
                  *)
                    echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" $source ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
                    rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" "$source" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
                    ;;
                esac
              done
            fi
          fi
        SCRIPT
      end
    end
  end
end
