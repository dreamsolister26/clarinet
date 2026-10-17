#!/bin/bash

# repo init
repo init -u https://github.com/aobuta-project/android_manifest.git -b lineage-24.0 --git-lfs --depth=1

# device source
git clone https://github.com/MinamiQuartet/minami_manifest.git -b lineage-24.0 .repo/local_manifests

# Crave Sync + remove dirty
/opt/crave/resync.sh
repo sync -c --force-sync --force-remove-dirty --no-tags --no-clone-bundle # For fixing sync error

# setup build enviroment
. build/envsetup.sh

# export
export BUILD_USERNAME=eupho
export BUILD_HOSTNAME=minami
export KBUILD_BUILD_USER="kumiko" 
export KBUILD_BUILD_HOST="kitauji_quartet"
export TARGET_INCLUDE_GRAMOPHONE=true

# starting build
lunch lineage_earth-cp2a-userdebug
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
