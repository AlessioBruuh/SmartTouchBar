#!/bin/zsh
# Compila SmartTouchBar.app (nessun Xcode project necessario).
set -e
cd "${0:A:h}"

APP=SmartTouchBar.app
rm -rf $APP
mkdir -p $APP/Contents/MacOS

cat > $APP/Contents/Info.plist <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleIdentifier</key><string>com.smarttouchbar.app</string>
  <key>CFBundleName</key><string>SmartTouchBar</string>
  <key>CFBundleExecutable</key><string>SmartTouchBar</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>LSMinimumSystemVersion</key><string>11.0</string>
  <key>LSUIElement</key><true/>
  <key>NSAppleEventsUsageDescription</key><string>Per mostrare pulsanti adatti al sito aperto nel browser.</string>
</dict>
</plist>
EOF

# Binario universale: Intel + Apple Silicon
TMP=$(mktemp -d)
for arch in x86_64 arm64; do
  swiftc -O -target $arch-apple-macos11 \
    -import-objc-header Bridging.h main.swift \
    -o $TMP/SmartTouchBar-$arch
done
lipo -create $TMP/SmartTouchBar-x86_64 $TMP/SmartTouchBar-arm64 \
  -output $APP/Contents/MacOS/SmartTouchBar
rm -rf $TMP

codesign --force -s - -r="designated => identifier \"com.smarttouchbar.app\"" $APP
echo "OK: $PWD/$APP"
