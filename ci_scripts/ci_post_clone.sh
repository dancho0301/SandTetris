#!/bin/sh

# Xcode Cloud ビルド用スクリプト
# リポジトリクローン後に自動実行されます

set -e

echo "========================================="
echo "🔧 Xcode Cloud環境をセットアップ中..."
echo "========================================="

# 現在のディレクトリを表示
echo "Current directory: $(pwd)"

# 環境変数を表示
echo "CI_WORKSPACE: ${CI_WORKSPACE:-not set}"
echo "CI_XCODE_PATH: ${CI_XCODE_PATH:-not set}"

# Xcode Command Line Toolsのパスを設定
if [ -n "$CI_XCODE_PATH" ]; then
    echo "Setting Xcode path to: $CI_XCODE_PATH"
    sudo xcode-select -s "$CI_XCODE_PATH"
else
    echo "⚠️ CI_XCODE_PATH is not set, using default"
fi

# Xcodeのバージョンを表示
echo "Xcode version:"
xcodebuild -version

# CocoaPodsのバージョンを確認
if command -v pod &> /dev/null
then
    echo "CocoaPods version:"
    pod --version
else
    echo "CocoaPods not found, installing..."
    sudo gem install cocoapods -v 1.15.2
    echo "Installed CocoaPods version:"
    pod --version
fi

# プロジェクトルートディレクトリに移動
# ci_scriptsディレクトリから1つ上の階層に移動
cd "$(dirname "$0")/.."
PROJECT_ROOT="$(pwd)"

echo "Project root: $PROJECT_ROOT"

# ディレクトリ内容を確認
echo "Files in project root:"
ls -la

echo "========================================="
echo "📦 pod installを実行中..."
echo "========================================="

# Podfileの存在を確認
if [ ! -f "Podfile" ]; then
    echo "❌ Error: Podfile not found in $PROJECT_ROOT"
    echo "Available files:"
    ls -la
    exit 1
fi

echo "✅ Podfile found!"

# pod installの前にメインプロジェクトからMetal Toolchainのパスを削除
echo "Pre-cleaning: Removing Metal Toolchain paths from main project..."
if [ -f "sandtetris.xcodeproj/project.pbxproj" ]; then
    # MetalToolchainを含む行を削除（macOS sedの構文）
    sed -i '' '/MetalToolchain/d' "sandtetris.xcodeproj/project.pbxproj" 2>/dev/null || \
    sed -i.backup '/MetalToolchain/d' "sandtetris.xcodeproj/project.pbxproj"
    echo "✅ Pre-cleaned main project file"
fi

# CocoaPodsのキャッシュをクリア
pod cache clean --all

# pod install実行
pod install --verbose

# .xcworkspaceが生成されたか確認
if [ ! -d "sandtetris.xcworkspace" ]; then
    echo "❌ Error: sandtetris.xcworkspace was not created!"
    exit 1
fi

echo "========================================="
echo "🔧 Xcode Cloud用のスクリプト修正..."
echo "========================================="

# Metal Toolchainの不正なパスを削除
echo "Post-cleaning: Removing Metal Toolchain paths from all project files..."

# メインプロジェクトからMetal Toolchainのパスを削除（再度実行）
if [ -f "sandtetris.xcodeproj/project.pbxproj" ]; then
    echo "Post-cleaning sandtetris.xcodeproj..."
    # MetalToolchainを含む行の数を確認
    METAL_COUNT=$(grep -c "MetalToolchain" "sandtetris.xcodeproj/project.pbxproj" 2>/dev/null || echo "0")
    echo "Found $METAL_COUNT lines containing MetalToolchain in main project"

    if [ "$METAL_COUNT" != "0" ]; then
        sed -i '' '/MetalToolchain/d' "sandtetris.xcodeproj/project.pbxproj" 2>/dev/null || \
        sed -i.backup '/MetalToolchain/d' "sandtetris.xcodeproj/project.pbxproj"
        echo "✅ Removed MetalToolchain references from main project"
    else
        echo "✅ No MetalToolchain references in main project"
    fi
fi

# Podsプロジェクトが存在する場合も修正
if [ -f "Pods/Pods.xcodeproj/project.pbxproj" ]; then
    echo "Post-cleaning Pods.xcodeproj..."
    # MetalToolchainを含む行の数を確認
    METAL_COUNT=$(grep -c "MetalToolchain" "Pods/Pods.xcodeproj/project.pbxproj" 2>/dev/null || echo "0")
    echo "Found $METAL_COUNT lines containing MetalToolchain in Pods project"

    if [ "$METAL_COUNT" != "0" ]; then
        sed -i '' '/MetalToolchain/d' "Pods/Pods.xcodeproj/project.pbxproj" 2>/dev/null || \
        sed -i.backup '/MetalToolchain/d' "Pods/Pods.xcodeproj/project.pbxproj"
        echo "✅ Removed MetalToolchain references from Pods project"
    else
        echo "✅ No MetalToolchain references in Pods project"
    fi
fi

# 全ての.xcconfig ファイルもチェック
echo "Checking .xcconfig files for MetalToolchain..."
find Pods -name "*.xcconfig" -type f 2>/dev/null | while read xcconfig_file; do
    if grep -q "MetalToolchain" "$xcconfig_file" 2>/dev/null; then
        echo "Found MetalToolchain in $xcconfig_file, removing..."
        sed -i '' '/MetalToolchain/d' "$xcconfig_file" 2>/dev/null || \
        sed -i.backup '/MetalToolchain/d' "$xcconfig_file"
        echo "✅ Cleaned $xcconfig_file"
    fi
done

# CocoaPodsのリソーススクリプトを完全に書き換える
# Xcode Cloudのrealpathは-mオプションをサポートしていない
RESOURCES_SCRIPT="Pods/Target Support Files/Pods-sandtetris/Pods-sandtetris-resources.sh"

# Podsディレクトリ全体のパーミッションを修正
echo "Setting permissions for Pods directory..."
chmod -R u+w Pods/ 2>/dev/null || true

# リソーススクリプトの完全書き換え
if [ -f "$RESOURCES_SCRIPT" ]; then
    echo "Completely rewriting $RESOURCES_SCRIPT for Xcode Cloud compatibility"

    # バックアップを作成
    cp "$RESOURCES_SCRIPT" "${RESOURCES_SCRIPT}.backup"

    # 完全に新しいスクリプトを書き込む
    cat > "$RESOURCES_SCRIPT" << 'SCRIPT_EOF'
#!/bin/sh
set -e
set -u
set -o pipefail

# Xcode Cloud対応版のリソースコピースクリプト
# realpath -m を使用せず、標準的なbashコマンドのみを使用

if [ -z ${UNLOCALIZED_RESOURCES_FOLDER_PATH+x} ]; then
  echo "UNLOCALIZED_RESOURCES_FOLDER_PATH is not set, exiting"
  exit 0
fi

RSYNC_PROTECT_TMP_FILES=(--filter "P .*.??????")

# リソースファイルのリストを処理
if [ -n "${SCRIPT_INPUT_FILE_COUNT:-}" ]; then
  for i in $(seq 0 $(($SCRIPT_INPUT_FILE_COUNT - 1))); do
    VAR_NAME="SCRIPT_INPUT_FILE_$i"
    eval RESOURCE_PATH=\$$VAR_NAME

    if [ -z "$RESOURCE_PATH" ]; then
      continue
    fi

    echo "Processing resource: $RESOURCE_PATH"

    case "$RESOURCE_PATH" in
      *.storyboard)
        echo "Compiling storyboard: $RESOURCE_PATH"
        BASENAME=$(basename "$RESOURCE_PATH" .storyboard)
        ibtool --reference-external-strings-file --errors --warnings --notices \
          --minimum-deployment-target ${IPHONEOS_DEPLOYMENT_TARGET:-17.0} \
          --output-format human-readable-text \
          --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${BASENAME}.storyboardc" \
          "$RESOURCE_PATH" \
          --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS:-}
        ;;
      *.xib)
        echo "Compiling XIB: $RESOURCE_PATH"
        BASENAME=$(basename "$RESOURCE_PATH" .xib)
        ibtool --reference-external-strings-file --errors --warnings --notices \
          --minimum-deployment-target ${IPHONEOS_DEPLOYMENT_TARGET:-17.0} \
          --output-format human-readable-text \
          --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${BASENAME}.nib" \
          "$RESOURCE_PATH" \
          --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS:-}
        ;;
      *.framework)
        echo "Copying framework: $RESOURCE_PATH"
        if [ -n "${FRAMEWORKS_FOLDER_PATH:-}" ]; then
          rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" "$RESOURCE_PATH" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
        fi
        ;;
      *.xcdatamodel)
        echo "Compiling Core Data model: $RESOURCE_PATH"
        BASENAME=$(basename "$RESOURCE_PATH" .xcdatamodel)
        xcrun momc "$RESOURCE_PATH" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${BASENAME}.mom"
        ;;
      *.xcdatamodeld)
        echo "Compiling Core Data model: $RESOURCE_PATH"
        BASENAME=$(basename "$RESOURCE_PATH" .xcdatamodeld)
        xcrun momc "$RESOURCE_PATH" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${BASENAME}.momd"
        ;;
      *.xcmappingmodel)
        echo "Compiling mapping model: $RESOURCE_PATH"
        BASENAME=$(basename "$RESOURCE_PATH" .xcmappingmodel)
        xcrun mapc "$RESOURCE_PATH" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${BASENAME}.cdm"
        ;;
      *.xcassets)
        echo "Asset catalog will be compiled by Xcode: $RESOURCE_PATH"
        # xcassetsはXcodeが自動的にコンパイルするため、ここでは何もしない
        ;;
      *.bundle)
        echo "Copying bundle: $RESOURCE_PATH"
        rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" "$RESOURCE_PATH" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
        ;;
      *)
        echo "Copying resource: $RESOURCE_PATH"
        rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" "$RESOURCE_PATH" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
        ;;
    esac
  done
fi

echo "✅ Resource copying completed successfully"
SCRIPT_EOF

    # 実行権限を付与
    chmod +x "$RESOURCES_SCRIPT"

    echo "✅ Resources script completely rewritten"

    # 新しいスクリプトの内容を確認
    echo "New script content (first 40 lines):"
    head -40 "$RESOURCES_SCRIPT"
else
    echo "⚠️ Resources script not found at $RESOURCES_SCRIPT"
    # Podsディレクトリの構造を確認
    echo "Pods directory structure:"
    ls -la "Pods/Target Support Files/" 2>/dev/null || echo "Directory not found"
fi

echo "========================================="
echo "✅ CocoaPodsのセットアップが完了しました"
echo "========================================="

# 生成されたファイルを確認
echo "Generated files:"
ls -la | grep -E "\.xc"
