#!/bin/bash

# repo init
repo init -u https://github.com/Lunaris-AOSP/android -b 16.2 --git-lfs --depth=1

# sync + remove dirty
/opt/crave/resync.sh

# device source 
git clone https://github.com/MinamiQuartet/android_device_xiaomi_earth.git -b Lunaris-16.2 device/xiaomi/earth

# patching build/soong
cd vendor/lineage
curl -LSs "https://github.com/dreamsolister26/vendor_lunaris/commit/5f52fddccb4036e113ace9de8ae5437d225f999c.patch" -o vendor.patch
git am vendor.patch && rm -f vendor.patch
cd ../..

export BUILD_USERNAME=yuuko
export BUILD_HOSTNAME=minami

# setup env & build
. build/envsetup.sh
lunch lineage_earth-bp4a-userdebug
mka bacon

# Upload files to gofile
echo "Upload to gofile will be started..."
if [ -f out/target/product/earth/*2026*.zip ]; then
    wget https://raw.githubusercontent.com/lordgaruda/GoFile-Upload/refs/heads/master/upload.sh
    chmod +x upload.sh && ./upload.sh out/target/product/earth/boot.img && ./upload.sh out/target/product/earth/*2026*.zip
    echo "Upload Done!"
else
    echo "No zip found in out/ dir!" 
    exit 1
fi
