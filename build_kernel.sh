#!/bin/bash
set -e

export ARCH=arm64
export SUBARCH=arm64
mkdir -p out

CLANG_DIR=$(find $(pwd)/toolchain/clang-19 -maxdepth 2 -type d -name "bin" -path "*r530567*" | head -n1 | xargs dirname)
export PATH=$CLANG_DIR/bin:$PATH

echo "Using clang from: $CLANG_DIR"
$CLANG_DIR/bin/clang --version

make -C $(pwd) O=$(pwd)/out ARCH=arm64 vendor/a52sxq_eur_open_defconfig

make -j$(nproc) -C $(pwd) O=$(pwd)/out \
    ARCH=arm64 CC=clang LLVM=1 LLVM_IAS=1 CROSS_COMPILE=aarch64-linux-gnu- \
    CONFIG_SECTION_MISMATCH_WARN_ONLY=y

cp out/arch/arm64/boot/Image $(pwd)/arch/arm64/boot/Image
mkdir -p out_modules
find out -name "*.ko" -exec cp {} out_modules/ \;
