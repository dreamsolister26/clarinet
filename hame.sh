#!/bin/bash

# repo init
repo init --depth=1 --no-repo-verify --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 17 -g default,-mips,-darwin,-notdefault

# sync + remove dirty
/opt/crave/resync.sh
repo sync -c --force-sync --force-remove-dirty --no-tags --no-clone-bundle # For fixing sync error

# device source 
git clone https://github.com/MinamiQuartet/android_device_xiaomi_earth.git -b Infinity-17 device/xiaomi/earth

# patching build/soong
cd build/soong
wget https://raw.githubusercontent.com/dreamsolister26/clarinet/refs/heads/main/soong.patch && patch -p1 < soong.patch
rm -f soong.patch && cd ../..

# build start
. build/envsetup.sh

export BUILD_USERNAME=yuuko
export BUILD_HOSTNAME=minami
export SOONG_NINJA=ninja

lunch infinity_earth-userdebug
mka bacon

# Upload files to gofile
echo "Upload to gofile will be started..."
if [ -f out/target/product/earth/*2026*.zip ]; then
    wget https://raw.githubusercontent.com/lordgaruda/GoFile-Upload/refs/heads/master/upload.sh
    chmod +x upload.sh && ./upload.sh out/target/product/earth/boot.img && ./upload.sh out/target/product/earth/*2026*.zip
    cd build/soong && git restore . && cd ../.. && rm -f upload.sh
    echo "Upload Done!"
else
    cd build/soong && git restore . && cd ../..
    echo "No zip found in out/ dir!" 
    exit 1
fi
