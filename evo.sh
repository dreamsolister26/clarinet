#!/bin/bash

# repo init
repo init -u https://github.com/sweet-bullet/evolution_manifest.git -b cnb --git-lfs --depth=1

# sync + remove dirty
/opt/crave/resync.sh
repo sync -c --force-sync --force-remove-dirty --no-tags --no-clone-bundle # For fixing sync error

# device source 
git clone https://github.com/MinamiQuartet/android_device_xiaomi_earth.git -b EvolutionX-17 device/xiaomi/earth

export BUILD_USERNAME=kumiko
export BUILD_HOSTNAME=minami

# build start
. build/envsetup.sh
lunch lineage_earth-cp2a-userdebug
m evolution

# Upload files to gofile
echo "Upload to gofile will be started..."
if [ -f out/target/product/earth/*202609*.zip ]; then
    wget https://raw.githubusercontent.com/lordgaruda/GoFile-Upload/refs/heads/master/upload.sh
    chmod +x upload.sh && ./upload.sh out/target/product/earth/*202609*.zip
    echo "Upload Done!"
else
    echo "No zip found in out/ dir!" 
    exit 1
fi
