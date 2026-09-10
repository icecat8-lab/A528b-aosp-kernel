#!/bin/bash

export ARCH=arm64
export SUBARCH=arm64
mkdir -p out

CLANG_DIR=$(find $(pwd)/toolchain/clang-19 -maxdepth 2 -type d -name "bin" | head -n1 | xargs dirname)
export PATH=$CLANG_DIR/bin:$PATH

echo "Using clang from: $CLANG_DIR"
$CLANG_DIR/bin/clang --version

CLANG_TRIPLE=aarch64-linux-gnu-
KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"

make -j$(nproc) -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV \
    ARCH=arm64 LLVM=1 LLVM_IAS=1 CLANG_TRIPLE=$CLANG_TRIPLE \
    CONFIG_SECTION_MISMATCH_WARN_ONLY=y \
    vendor/a52sxq_eur_open_defconfig

make -j$(nproc) -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV \
    ARCH=arm64 LLVM=1 LLVM_IAS=1 CLANG_TRIPLE=$CLANG_TRIPLE \
    CONFIG_SECTION_MISMATCH_WARN_ONLY=y

cp out/arch/arm64/boot/Image $(pwd)/arch/arm64/boot/Image
mkdir -p out_modules
find out -name "*.ko" -exec cp {} out_modules/ \;
