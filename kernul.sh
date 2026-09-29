#!/bin/bash

# Configuration and export
KERNEL_REPO=https://github.com/MinamiQuartet/android_kernel_xiaomi_earth.git
KERNEL_BRANCH=ksu-testing
CLANG_URL=https://github.com/dreamsolister26/clarinet/releases/download/16165221/clang-r614150.tar.gz

export ZIPNAME="test"
export TIMESTAMP="$(date +"%Y%m%d")-$(date +"%H%M%S")"
export CODENAME="earth"
export TZ="Asia/Jakarta"
export KBUILD_BUILD_USER="kumiko" 
export KBUILD_BUILD_HOST="kitauji_quartet"	

# Clone kernel tree
git clone $KERNEL_REPO -b $KERNEL_BRANCH kernel --depth=1
cd kernel
echo "kernel has been cloned"

# Cloning clang
mkdir -p clang
wget $CLANG_URL -d clang/
export PATH=$PWD/clang/bin:$PATH

# Clone anykernel
git clone https://github.com/HiroZukki/Anykernel3 anykernel

# Start build
make O=out ARCH=arm64 earth_defconfig
make -j$(nproc --all) ARCH=arm64 SUBARCH=arm64 O=out LLVM=1 LLVM_IAS=1 CC="clang" AR="llvm-ar" NM="llvm-nm" LD="ld.lld -S" OBJCOPY="llvm-objcopy" OBJDUMP="llvm-objdump" STRIP="llvm-strip" CLANG_TRIPLE="aarch64-linux-gnu-" CROSS_COMPILE="aarch64-linux-gnu-" CROSS_COMPILE_ARM32="arm-linux-gnueabi-" CROSS_COMPILE_COMPAT="arm-linux-gnueabi-" CONFIG_DEBUG_SECTION_MISMATCH=y
	
# Anykernel3
if [ -f out/arch/arm64/boot/Image.gz-dtb ]; then
    cp out/arch/arm64/boot/Image.gz-dtb anykernel/
    cd anykernel && zip -r9 "../../Anykernel3-${ZIPNAME}-${TIMESTAMP}-${CODENAME}.zip" * -x '.git*'
    cd ..
else 
    exit 1
fi
