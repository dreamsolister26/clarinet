#!/bin/bash

# repo init
repo init -u https://github.com/crdroidandroid/android.git -b 17.0 --git-lfs --depth=1

# Crave Sync + remove dirty
/opt/crave/resync.sh
repo sync -c --force-sync --force-remove-dirty --no-tags --no-clone-bundle # For fixing sync error

# device source
git clone https://github.com/MinamiQuartet/android_device_xiaomi_earth.git -b crDroid-17 device/xiaomi/earth

# Patching source
cd build/soong
curl -LSs "https://github.com/sweet-bullet/build_soong_evo/commit/47b4d25fbb8e1713f1304dc78f357a0d858946a2.patch" | git am
cd ../..

cd frameworks/base
curl -LSs "https://github.com/eupho26/android_frameworks_base/commit/bf2b23d09bc6f5d2f1207895bcff075a823186f4.patch" | git am
cd ../..

cd packages/apps/crDroidSettings
curl -LSs "https://github.com/eupho26/android_packages_apps_crDroidSettings/commit/f0e68b37e3705e8034e2b5cc53d3fc775a8ca1f6.patch" | git am
cd ../../..

export BUILD_USERNAME=eupho
export BUILD_HOSTNAME=minami

# build start
. build/envsetup.sh
brunch earth userdebug

# Upload files to gofile
echo "Upload to gofile will be started..."
if [ -f out/target/product/earth/*2026*.zip ]; then
    wget https://raw.githubusercontent.com/lordgaruda/GoFile-Upload/refs/heads/master/upload.sh
    chmod +x upload.sh ; ./upload.sh out/target/product/earth/*2026*.zip
    echo "Upload Done!"
else
    echo "No zip found!"
    exit 1
fi
