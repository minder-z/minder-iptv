#!/bin/bash
# 编译并打包成 小满 IPTV.app
set -euo pipefail
cd "$(dirname "$0")"

swift build -c release

# 图标：由 tools/make_icon.swift 生成
if [ ! -f AppIcon.icns ]; then
  TMP=$(mktemp -d)
  swift tools/make_icon.swift "$TMP/icon.png"
  mkdir "$TMP/AppIcon.iconset"
  for s in 16 32 128 256 512; do
    sips -z $s $s "$TMP/icon.png" --out "$TMP/AppIcon.iconset/icon_${s}x${s}.png" >/dev/null
    sips -z $((s*2)) $((s*2)) "$TMP/icon.png" --out "$TMP/AppIcon.iconset/icon_${s}x${s}@2x.png" >/dev/null
  done
  iconutil -c icns "$TMP/AppIcon.iconset" -o AppIcon.icns
  rm -rf "$TMP"
fi

VERSION=$(cat VERSION)
BUILD=$(git rev-list --count HEAD 2>/dev/null || echo 1)
APP="小满 IPTV.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp .build/release/MinderIPTV "$APP/Contents/MacOS/MinderIPTV"
cp AppIcon.icns "$APP/Contents/Resources/"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>小满 IPTV</string>
  <key>CFBundleDisplayName</key><string>小满 IPTV</string>
  <key>CFBundleIdentifier</key><string>io.github.minder-z.minder-iptv</string>
  <key>CFBundleExecutable</key><string>MinderIPTV</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>$VERSION</string>
  <key>CFBundleVersion</key><string>$BUILD</string>
  <key>CFBundleDevelopmentRegion</key><string>en</string>
  <key>CFBundleAllowMixedLocalizations</key><true/>
  <key>CFBundleLocalizations</key>
  <array>
    <string>zh-Hans</string><string>zh-Hant</string><string>en</string><string>ja</string><string>ko</string>
    <string>fr</string><string>de</string><string>es</string><string>ru</string>
  </array>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>LSMinimumSystemVersion</key><string>14.0</string>
  <key>LSApplicationCategoryType</key><string>public.app-category.entertainment</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>NSAppTransportSecurity</key>
  <dict><key>NSAllowsArbitraryLoads</key><true/><key>NSAllowsArbitraryLoadsForMedia</key><true/></dict>
</dict>
</plist>
PLIST
# 各语言资源：有了这些 .lproj，macOS 才会用对应语言显示系统菜单；应用名也随语言变化
for lang in zh-Hans zh-Hant en ja ko fr de es ru; do
  case $lang in
    zh-Hans) NAME="小满 IPTV" ;;
    zh-Hant) NAME="小滿 IPTV" ;;
    *)       NAME="Minder IPTV" ;;
  esac
  mkdir -p "$APP/Contents/Resources/$lang.lproj"
  printf '"CFBundleName" = "%s";\n"CFBundleDisplayName" = "%s";\n' "$NAME" "$NAME" \
    > "$APP/Contents/Resources/$lang.lproj/InfoPlist.strings"
done

codesign --force --deep -s - "$APP"

# 发布用压缩包：./build_app.sh --zip
if [ "${1:-}" = "--zip" ]; then
  mkdir -p dist
  ZIP="dist/MinderIPTV-$VERSION.zip"
  rm -f "$ZIP"
  ditto -c -k --keepParent "$APP" "$ZIP"
  echo "📦 $ZIP"
fi
echo "✅ 已生成 $(pwd)/$APP"
