./build-llvm.py \
--defines LLVM_PARALLEL_COMPILE_JOBS=$(nproc) LLVM_PARALLEL_LINK_JOBS=$(nproc) CMAKE_C_FLAGS=-O3 CMAKE_CXX_FLAGS=-O3 \
--targets AArch64 ARM \
--projects clang lld lldb polly compiler-rt \
--no-update \
--lto thin \
--pgo kernel-defconfig \
--use-good-revision \
-i /home/ubuntu/toolchains/clang-r530567

# --bolt \
# --lto should not be used with '--build-stage1-only'
# --lto full requires more than 64 GB of memory

./build-binutils.py --targets aarch64-linux-gnu arm-linux-gnueabi --show-build-commands --binutils-folder src/binutils/binutils-2.27 --march native -i /home/ubuntu/toolchains/clang-r530567
