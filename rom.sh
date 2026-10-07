#!/bin/bash

# Check secrets file
source ".secrets"

# remove device source
rm -rf device/xiaomi/earth kernel/xiaomi/earth vendor/xiaomi/earth
rm -rf hardware/mediatek hardware/xiaomi device/mediatek/sepolicy_vndr

# setup git config
git config --global url."https://${GH_TOKEN}@github.com/".insteadOf "https://github.com/"

# repo init
repo init -u https://github.com/ShinkaiProject/shinkai_manifest.git -b heptakaideka --git-lfs --depth=1

# Crave Sync + remove dirty
/opt/crave/resync.sh
repo sync -c --force-sync --force-remove-dirty --no-tags --no-clone-bundle # For fixing sync error

# device source
git clone https://github.com/MinamiQuartet/android_device_xiaomi_earth.git -b Shinkai-17 device/xiaomi/earth

# patching build/soong
cd build/soong
curl -LSs "https://github.com/aobuta-prjkt/android_build_soong/commit/798709d705ee46dac76cdad4432fd0ad12918e8e.patch" | git am
curl -LSs "https://github.com/aobuta-prjkt/android_build_soong/commit/01a631a4a9bcb308e26bcdf39382469392af5c22.patch" | git am
cd ../..

# patching frameworks/base
cd frameworks/base
curl -LSs "https://github.com/aobuta-prjkt/android_frameworks_base/commit/861936436049e8e1edf573e86c2e5aa834043c08.patch" | git am
cd ../..

# setup build enviroment
. build/envsetup.sh

# export
export BUILD_USERNAME=eupho
export BUILD_HOSTNAME=minami
export KBUILD_BUILD_USER="kumiko" 
export KBUILD_BUILD_HOST="kitauji_quartet"
export SOONG_NINJA=ninja

# starting build
breakfast earth userdebug
mka shinkai

# Upload files to gofile
echo "Upload to gofile will be started..."
if [ -f out/target/product/earth/*2026*.zip ]; then
    wget https://raw.githubusercontent.com/lordgaruda/GoFile-Upload/refs/heads/master/upload.sh
    chmod +x upload.sh ; ./upload.sh out/target/product/earth/Shinkai*.zip
    echo "Upload Done!"
else
    echo "No zip found!"
    exit 1
fi
