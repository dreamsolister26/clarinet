#!/bin/bash

# repo init
repo init -u https://github.com/aobuta-project/lunaris_manifest.git -b 16.2 --git-lfs --depth=1
/opt/crave/resync.sh

# device source
git clone https://github.com/MinamiQuartet/android_device_xiaomi_earth.git -b Lunaris-16.2 device/xiaomi/earth

# setup build enviroment
. build/envsetup.sh

# export
export BUILD_USERNAME=eupho
export BUILD_HOSTNAME=minami
export KBUILD_BUILD_USER="kumiko" 
export KBUILD_BUILD_HOST="kitauji_quartet"

# starting build
lunch lineage_earth-bp4a-userdebug
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
