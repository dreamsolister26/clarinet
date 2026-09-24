#!/bin/bash

# Export
export ZIPNAME="test"
export TIMESTAMP="$(date +"%Y%m%d")-$(date +"%H%M%S")"
export CODENAME="earth"
export TZ="Asia/Jakarta"
export KBUILD_BUILD_USER="kumiko" 
export KBUILD_BUILD_HOST="kitauji_quartet"	

if [ -d clang/ ]; then
    echo "Clang has been cloned, starting build..."
else
    echo "Clang not found!. Starting cloning clang..."
    git clone --depth=1 https://github.com/LineageOS/android_prebuilts_clang_kernel_linux-x86_clang-r416183b.git clang
    echo "Clang has been cloned, starting build...."
fi

if [ -d anykernel/ ]; then
   echo "anykernel has been cloned"
else
   echo "anykernel not found!, start cloning..."
   git clone https://github.com/HiroZukki/Anykernel3 anykernel
fi

# setup clang path
export PATH=$PWD/clang/bin:$PATH

make O=out ARCH=arm64 earth_defconfig
make -j$(nproc --all) ARCH=arm64 SUBARCH=arm64 O=out LLVM=1 LLVM_IAS=1
	CC="clang" \
	AR="llvm-ar" \
	NM="llvm-nm" \
	LD="ld.lld -S" \
	OBJCOPY="llvm-objcopy" \
	OBJDUMP="llvm-objdump" \
	STRIP="llvm-strip" \
	CLANG_TRIPLE="aarch64-linux-gnu-" \
	CROSS_COMPILE="aarch64-linux-gnu-" \
	CROSS_COMPILE_ARM32="arm-linux-gnueabi-" \
	CROSS_COMPILE_COMPAT="arm-linux-gnueabi-" \
	CONFIG_DEBUG_SECTION_MISMATCH=y
	
# Anykernel3
if [ -f out/arch/arm64/boot/Image.gz-dtb ]; then
    cp out/arch/arm64/boot/Image.gz-dtb anykernel/
    cd anykernel && zip -r9 "../Anykernel3-${ZIPNAME}-${TIMESTAMP}-${CODENAME}.zip" * -x '.git*'
    cd ..
else 
    exit 1
fi
