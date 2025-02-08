#!/usr/bin/env bash
./build-llvm.py \
--defines LLVM_PARALLEL_COMPILE_JOBS=$(nproc) LLVM_PARALLEL_LINK_JOBS=$(nproc) CMAKE_C_FLAGS=-O3 CMAKE_CXX_FLAGS=-O3 \
--targets AArch64 ARM \
--projects clang lld polly compiler-rt lldb \
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
