#!/bin/bash

# repo init
repo init -u https://github.com/sweet-bullet/evolution_manifest.git -b cnb --git-lfs --depth=1
/opt/crave/resync.sh # sync source

# device source
rm -rf device/xiaomi/earth
git clone https://github.com/HiroZukki/device_xiaomi_earth.git -b EvolutionX-17 device/xiaomi/earth --depth=1

# build start
. build/envsetup.sh

export BUILD_USERNAME=zukki
export BUILD_HOSTNAME=sweet_bullet
export SOONG_NINJA=ninja

# start build
lunch lineage_earth-cp2a-userdebug
make installclean
m evolution

# Upload files to gofile
echo "Upload to gofile will be started..."
if [ -f out/target/product/earth/*202609*.zip ]; then
    wget https://raw.githubusercontent.com/lordgaruda/GoFile-Upload/refs/heads/master/upload.sh
    chmod +x upload.sh ; ./upload.sh out/target/product/earth/*202609*.zip
    echo "Upload Done!"
else
    echo "No zip found in out/ dir!" 
    exit 1
fi
