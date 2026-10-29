#!/bin/bash

# repo init
repo init -u https://github.com/aobuta-project/lumine_manifest.git -b camellia --git-lfs --depth=1

# sync
/opt/crave/resync.sh
repo sync -c --force-sync --force-remove-dirty --no-tags --no-clone-bundle

# remove device source 
rm -rf device/xiaomi/earth vendor/xiaomi/earth kernel/xiaomi/earth
rm -rf hardware/mediatek hardware/xiaomi device/mediatek/sepolicy_vndr

# device source
git clone https://github.com/MinamiQuartet/android_device_xiaomi_earth.git -b Lumine-17 device/xiaomi/earth

# Patching source
cd vendor/lumine
curl -s "https://raw.githubusercontent.com/dreamsolister26/clarinet/refs/heads/main/0001-release-Disable-native-app-zygote-prototype-flags-in.patch" | git am
cd ../..

# setup build enviroment
. build/envsetup.sh

# export
export BUILD_USERNAME=eupho
export BUILD_HOSTNAME=minami
export KBUILD_BUILD_USER="kumiko" 
export KBUILD_BUILD_HOST="kitauji_quartet"

# starting build
lunch earth-cp2a-userdebug
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
