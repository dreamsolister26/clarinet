#!/bin/bash

# repo init
repo init -u https://github.com/crdroidandroid/android.git -b 17.0 --git-lfs --no-clone-bundle --depth=1

# Crave Sync + remove dirty
/opt/crave/resync.sh
repo sync -c --force-sync --force-remove-dirty --no-tags --no-clone-bundle # For fixing sync error

# device source
git clone https://github.com/MinamiQuartet/android_device_xiaomi_earth.git -b crDroid-17 device/xiaomi/earth

# patching build/soong
cd build/soong
curl -LSs "https://raw.githubusercontent.com/eupho26/krep_sekerip/refs/heads/main/patch_soong.patch" | git am
cd ../..

# patching fwb
cd frameworks/base
curl -LSs "https://raw.githubusercontent.com/eupho26/krep_sekerip/refs/heads/main/signal.patch" | git am
cd ../..

cd packages/apps/crDroidSettings
curl -LSs "https://raw.githubusercontent.com/eupho26/krep_sekerip/refs/heads/main/maintainer.patch" | git am
cd ../../..

# setup build enviroment
. build/envsetup.sh

# export
export BUILD_USERNAME=eupho
export BUILD_HOSTNAME=minami
export KBUILD_BUILD_USER="kumiko" 
export KBUILD_BUILD_HOST="kitauji_quartet"

# starting build
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
