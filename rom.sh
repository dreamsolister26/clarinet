#!/bin/bash

# remove device source
rm -rf device/xiaomi/earth kernel/xiaomi/earth vendor/xiaomi/earth
rm -rf hardware/xiaomi hardware/mediatek device/mediatek/sepolicy_vndr

# repo init
repo init -u https://github.com/sweet-bullet/evolution_manifest.git -b cnb --git-lfs --depth=1

# sync + remove dirty
/opt/crave/resync.sh
repo sync -c --force-sync --force-remove-dirty --no-tags --no-clone-bundle # For fixing sync error

# device source 
git clone https://github.com/MinamiQuartet/android_device_xiaomi_earth.git -b EvolutionX-17 device/xiaomi/earth

export BUILD_USERNAME=zukki
export BUILD_HOSTNAME=sweet_bullet

# build start
. build/envsetup.sh
lunch lineage_earth-cp2a-userdebug
make installclean
m evolution

# Upload files to gofile
echo "Upload to gofile will be started..."
if [ -f out/target/product/earth/*202609*.zip ]; then
    wget https://raw.githubusercontent.com/lordgaruda/GoFile-Upload/refs/heads/master/upload.sh
    chmod +x upload.sh && ./upload.sh out/target/product/earth/boot.img && ./upload.sh out/target/product/earth/*202609*.zip
    rm -f upload.sh
    echo "Upload Done!"
else
    echo "No zip found in out/ dir!" 
    exit 1
fi
