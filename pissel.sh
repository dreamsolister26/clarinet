#!/bin/bash

# remove device source
rm -rf device/xiaomi/earth kernel/xiaomi/earth vendor/xiaomi/earth
rm -rf hardware/mediatek hardware/xiaomi device/mediatek/sepolicy_vndr

# repo init
repo init -u https://github.com/aobuta-prjkt/pixelos_manifest.git -b seventeen --git-lfs --depth=1

# Crave Sync + remove dirty
/opt/crave/resync.sh
repo sync -c --force-sync --force-remove-dirty --no-tags --no-clone-bundle # For fixing sync error

# device source
git clone https://github.com/MinamiQuartet/android_device_xiaomi_earth.git -b PixelOS-17 device/xiaomi/earth

# setup build enviroment
. build/envsetup.sh

# export
export BUILD_USERNAME=eupho
export BUILD_HOSTNAME=minami
export KBUILD_BUILD_USER="kumiko" 
export KBUILD_BUILD_HOST="kitauji_quartet"

# starting build
breakfast earth userdebug
make installclean
m pixelos

# Upload files to gofile
echo "Upload to gofile will be started..."
if [ -f out/target/product/earth/*2026*.zip ]; then
    wget https://raw.githubusercontent.com/lordgaruda/GoFile-Upload/refs/heads/master/upload.sh
    chmod +x upload.sh ; ./upload.sh out/target/product/earth/PixelOS_*.zip
    echo "Upload Done!"
else
    echo "No zip found!"
    exit 1
fi
