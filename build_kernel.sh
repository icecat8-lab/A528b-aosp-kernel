#!/bin/bash
set -e

export ARCH=arm64
export SUBARCH=arm64
export PROJECT_NAME=a52sxq
mkdir -p out

# Search for the valid clang binary dynamically under the toolchain folder
CLANG_BIN=$(find "$(pwd)/toolchain" -maxdepth 4 -type f -path "*/bin/clang" | head -n1)

if [ -z "$CLANG_BIN" ]; then
    echo "Error: Clang binary not found in toolchain directory!"
    exit 1
fi

CLANG_DIR=$(dirname "$(dirname "$CLANG_BIN")")
export PATH=$CLANG_DIR/bin:$PATH

echo "Using clang from: $CLANG_DIR"
$CLANG_DIR/bin/clang --version

KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"

make -j$(nproc) -C "$(pwd)" O="$(pwd)/out" $KERNEL_MAKE_ENV \
    ARCH=arm64 \
    vendor/a52sxq_eur_open_defconfig

sh "$(pwd)/scripts/config" --file out/.config \
    -d ARCH_SUNXI \
    -d ARCH_ALLWINNER \
    -d OF_ALL_DTBS \
    -d COMPILE_TEST

make -j$(nproc) -C "$(pwd)" O="$(pwd)/out" $KERNEL_MAKE_ENV \
    ARCH=arm64 \
    olddefconfig

make -j$(nproc) -C "$(pwd)" O="$(pwd)/out" $KERNEL_MAKE_ENV \
    ARCH=arm64 \
    CC=clang \
    CLANG_TRIPLE=aarch64-linux-gnu- \
    CROSS_COMPILE=aarch64-linux-gnu- \
    LLVM=1 \
    LLVM_IAS=1 \
    CONFIG_SECTION_MISMATCH_WARN_ONLY=y

cp out/arch/arm64/boot/Image "$(pwd)/arch/arm64/boot/Image"
mkdir -p out_modules
find out -name "*.ko" -exec cp {} out_modules/ \;
