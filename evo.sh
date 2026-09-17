#!/bin/bash

# repo init
repo init -u https://github.com/LineageOS/android.git -b lineage-24.0 --git-lfs --depth=1

# sync + remove dirty
/opt/crave/resync.sh
repo sync -c --force-sync --force-remove-dirty --no-tags --no-clone-bundle # For fixing sync error

# device source
git clone https://github.com/MinamiQuartet/android_device_xiaomi_earth.git -b lineage-24.0 device/xiaomi/earth
git clone https://github.com/MinamiQuartet/vendor_xiaomi_earth.git -b lineage-24.0-ims vendor/xiaomi/earth --depth=1
git clone https://github.com/MinamiQuartet/android_kernel_xiaomi_earth.git -b lineage-24.0 kernel/xiaomi/earth --depth=1

# Hardware Repos
git clone https://github.com/LineageOS/android_hardware_xiaomi.git -b lineage-24.0 hardware/xiaomi
git clone https://github.com/LineageOS/android_hardware_mediatek.git -b lineage-24.0 hardware/mediatek
git clone https://github.com/LineageOS/android_device_mediatek_sepolicy_vndr.git -b lineage-24.0 device/mediatek/sepolicy_vndr

# Patching build/soong
cd build/soong
wget https://raw.githubusercontent.com/dreamsolister26/clarinet/refs/heads/main/soong.patch
patch -p1 < soong.patch && rm -f soong.patch
cd ../..

# build start
. build/envsetup.sh

export BUILD_USERNAME=zukki
export BUILD_HOSTNAME=sweet_bullet
export SOONG_NINJA=ninja

# start build
lunch lineage_earth-cp2a-userdebug
mka bacon

# Upload files to gofile
echo "Upload to gofile will be started..."
if [ -f out/target/product/earth/*202609*.zip ]; then
    wget https://raw.githubusercontent.com/lordgaruda/GoFile-Upload/refs/heads/master/upload.sh
    chmod +x upload.sh && ./upload.sh out/target/product/earth/*202609*.zip
    cd build/soong && git restore . && cd ../..
    echo "Upload & clean up Done!"
else
    cd build/soong && git restore . && cd ../..
    echo "No zip found in out/ dir!" 
    exit 1
fi
