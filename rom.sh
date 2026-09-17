#!/bin/bash

# init
repo init -u https://github.com/Pixelify-AOSP/platform_manifest.git -b 17 --git-lfs --depth=1

# Sync + remove dirty
/opt/crave/resync.sh
repo sync -c --force-sync --force-remove-dirty --no-tags --no-clone-bundle # For fixing sync error

# device source
git clone https://github.com/MinamiQuartet/android_device_xiaomi_earth.git -b ASCP-17 device/xiaomi/earth

# Patching build soong
cd build/soong
wget https://raw.githubusercontent.com/dreamsolister26/clarinet/refs/heads/main/soong.patch
patch -p1 < soong.patch && rm -f soong.patch
cd ../..

# Setup build
. build/envsetup.sh

export SOONG_NINJA=ninja
export BUILD_USERNAME=kumiko
export BUILD_HOSTNAME=kitauji_quartet

# start build
lunch earth-cp2a-userdebug 
mka bacon

# Upload
echo "upload to gofile..."
if [ -f out/target/product/earth/*202608*.zip ]; then
    wget https://raw.githubusercontent.com/lordgaruda/GoFile-Upload/refs/heads/master/upload.sh
    chmod +x upload.sh && ./upload.sh out/target/product/earth/PixelOS_*.zip
    cd build/soong && git restore . && cd ../..
    echo "upload & clean up done!"
else
    cd build/soong && git restore . && cd ../..
    echo "no zip found at out/ dir..."
    exit 1
fi
