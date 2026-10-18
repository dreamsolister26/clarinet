#!/bin/bash

# remove device source 
rm -rf device/xiaomi/earth kernel/xiaomi/earth vendor/xiaomi/earth
rm -rf hardware/mediatek hardware/xiaomi device/mediatek/sepolicy_vndr

# repo init
repo init --depth=1 --no-repo-verify --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 17 -g default,-mips,-darwin,-notdefault

# Crave Sync + remove dirty
/opt/crave/resync.sh
repo sync -c --force-sync --force-remove-dirty --no-tags --no-clone-bundle # For fixing sync error

# device source
git clone https://github.com/MinamiQuartet/android_device_xiaomi_earth.git -b Infinity-17 device/xiaomi/earth

# patch build/soong
cd build/soong
curl -LSs "https://github.com/aobuta-prjkt/android_build_soong/commit/798709d705ee46dac76cdad4432fd0ad12918e8e.patch" | git am
curl -LSs "https://github.com/aobuta-prjkt/android_build_soong/commit/01a631a4a9bcb308e26bcdf39382469392af5c22.patch" | git am
cd ../..

# disable blur
cd vendor/infinity
wget https://raw.githubusercontent.com/eupho26/krep_sekerip/refs/heads/main/disable_blurs.patch
git am disable_blurs.patch && rm -f disable_blurs.patch
cd ../..

# setup build enviroment
. build/envsetup.sh

# export
export BUILD_USERNAME=eupho
export BUILD_HOSTNAME=minami
export KBUILD_BUILD_USER="kumiko" 
export KBUILD_BUILD_HOST="kitauji_quartet"

# starting build
lunch infinity_earth-userdebug
make installclean
mka bacon

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
