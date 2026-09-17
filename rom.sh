#!/bin/bash

# init & sync
repo init -u https://github.com/sweet-bullet/evolution_manifest.git -b cnb --git-lfs --depth=1
/opt/crave/resync.sh
repo sync -c --force-sync --force-remove-dirty --no-tags --no-clone-bundle # For fixing sync error

# device source
git clone https://github.com/MinamiQuartet/android_device_xiaomi_earth.git -b EvolutionX-17 device/xiaomi/earth

# Setup build
. build/envsetup.sh

export SOONG_NINJA=ninja
export BUILD_USERNAME=kumiko
export BUILD_HOSTNAME=kitauji_quartet

# start build
lunch lineage_earth-cp2a-userdebug 
mka bacon

# Upload
echo "upload to gofile..."
if [ -f out/target/product/earth/*202608*.zip ]; then
    wget https://raw.githubusercontent.com/lordgaruda/GoFile-Upload/refs/heads/master/upload.sh
    chmod +x upload.sh ; ./upload.sh out/target/product/earth/PixelOS_*.zip
    echo "upload done!"
else
    echo "no zip found at out/ dir..."
    exit 1
fi
