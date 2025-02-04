#!/usr/bin/env bash
./build-llvm.py \
--targets AArch64 ARM \
--projects clang lld polly \
--no-update \
--lto thin \
--pgo kernel-defconfig \
--use-good-revision \
--check-targets clang lld llvm \
-i /home/ubuntu/toolchains/clang-tc

# --bolt \
# --lto should not be used with '--build-stage1-only'
# --lto full requires more than 64 GB of memory

./build-binutils.py --targets aarch64-linux-gnu arm-linux-gnueabi --march native -i /home/ubuntu/toolchains/clang-tc
