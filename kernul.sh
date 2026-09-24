#!/bin/bash

# kernel
git clone --depth=1 https://github.com/LineageOS/android_kernel_xiaomi_earth.git -b lineage-24.0 kernel
cd kernel && git checkout -b lineage-24.0-new
git fetch --unshallow

# new remote
git remote set-url origin https://github.com/MinamiQuartet/android_kernel_xiaomi_earth
git push -f origin lineage-24.0-new
