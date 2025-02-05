# Toolchain build scripts

The main purpose of this script is to compile the patched AOSP clang source code in a more standardized way. Why is this needed? When compiling the Android kernel on ARM64 devices (e.g., in LXC/chroot/proot environments or ARM-based computers like Mac M1), there are no compatible compilers available, as existing toolchains are designed for x86 platforms.

For compiling standard Linux kernels, using Ubuntu's built-in gcc and clang is generally fine. However, the Android kernel is different. The Android kernel undergoes multiple modifications (by Google, Qualcomm, and phone manufacturers), which makes it non-standard. Using generic compilers often leads to errors, warnings, boot failures, or other issues. To address this, Google developed AOSP Clang, which involves pulling LLVM source code, creating an initial compiler, testing the kernel and compiler, patching the compiler for errors, and repeating the process (e.g., clang 487747 has 111 patches).

In short, this script is used to standardize the compilation of patched AOSP clang source code on arm64 devices (phones, Raspberry Pi, Mac M1, etc.) under Linux/LXC/chroot/proot environments. The resulting toolchain closely resembles the official AOSP Clang, though full parity with the x86 version is unachievable without Google’s official ARM64 support.

**Usage (for LXC/chroot/proot environments on phones):**

1.  Clone this project. Note that this script is only suitable for newer clang versions, e.g., Clang 16.

    ```bash
    git clone -b new https://github.com/zenwav/tc-build.git tc-build
    ```

    ```bash
    cd tc-build/src/
    ```

    ```bash
    git clone https://android.googlesource.com/toolchain/llvm-project
    ```

    ```bash
    git clone https://android.googlesource.com/toolchain/llvm_android
    ```

    ```bash
    git clone https://android.googlesource.com/toolchain/binutils
    ```

    ```bash
    git clone https://android.googlesource.com/platform/external/toolchain-utils
    ```
    
2. Checkout specific Commits and Apply Patches:
    Then, refer to this [link](https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+/refs/heads/main), specifically the `manifest_xxxxx.xml` of the actually compiled x64 toolchain. Use `git checkout` to check out the corresponding commits, and similarly, check out the corresponding commits in `llvm_android`, `binutils`, and `toolchain-utils`. Then apply the patches to `llvm-project` and compile. Take `clang-r530567` as an example.

    ```bash
    cd llvm-project
    ```

    ```bash
    git checkout 97a699bf4812a18fb657c2779f5296a4ab2694d2
    ```

    ```bash
    cd ..
    ```

    ```bash
    cd llvm_android
    ```

    ```bash
    git checkout ab3ade05b26c45b59ac47b3779b7a6c999e6d634
    ```

    ```bash
    cd toolchain-utils
    ```

    ```bash
    git checkout dd1ee45a84cb07337f9d5d0a6769d9b865c6e620
    ```

    ```bash
    cd binutils
    ```

    ```bash
    git checkout c19795e958ed532462948fd14b1bdfd4f6e96e03
    ```

    ```bash
    cd ..
    ```

    ```bash
    python3 /home/ubuntu/tc-build/src/toolchain-utils/llvm_tools/patch_manager.py \
            --svn_version 530567 \
            --patch_metadata_file /home/ubuntu/tc-build/src/llvm_android/patches/PATCHES.json \
            --src_path /home/ubuntu/tc-build/src/llvm-project \
            --failure_mode fail
    ```

    ```bash
    cd ..
    ```

    ```bash
    chmod +x build.sh build-aosp-clang.sh
    ```

    ```bash
    ./build.sh
    ```
    -OR-

    ```bash
    ./build-aosp-clang.sh
    ```

3. Packaging

    ```bash
    cd /home/ubuntu/Toolchains
    ```

    ```bash
    XZ_OPT="-9" tar --warning=no-file-changed -cJf clang-r530567.tar.xz clang-r530567
    ```

    Or, install the multi-threaded packaging tool `pixz`:

    ```bash
    apt install pixz
    ```

    ```bash
    tar -I pixz -cf clang-r530567.tar.xz clang-r530567
    ```
## Credits
Based on the original Chinese guide authored by tomxi1997. The original guide can be found at [build-aosp-clang-for-arm64](https://github.com/tomxi1997/build-aosp-clang-for-arm64).


There are times where a tip of tree LLVM build will have some issue fixed and it isn't available to you, maybe because it isn't in a release or it isn't available through your distribution's package management system. At that point, to get that fix, LLVM needs to be compiled, which sounds scary but is [rather simple](https://llvm.org/docs/GettingStarted.html). The `build-llvm.py` script takes it a step farther by trying to optimize both LLVM's build time by:

* Trimming down a lot of things that kernel developers don't care about:
  * Documentation
  * LLVM tests
  * Ocaml bindings
  * libfuzzer
* Building with the faster tools available (in order of fastest to slowest):
  * clang + lld
  * clang/gcc + ld.gold
  * clang/gcc + ld.bfd

## Getting started

These scripts have been tested in a Docker image of the following distributions with the following packages installed. LLVM has [minimum host tool version requirements](https://llvm.org/docs/GettingStarted.html#software) so the latest stable version of the chosen distribution should be used whenever possible to ensure recent versions of the tools are used. Build errors from within LLVM are expected if the tool version is not recent enough, in which case it will need to be built from source or installed through other means.

* ### Debian/Ubuntu

  ```
  apt install bc \
              binutils-dev \
              bison \
              build-essential \
              ca-certificates \
              ccache \
              clang \
              cmake \
              curl \
              file \
              flex \
              git \
              libelf-dev \
              libssl-dev \
              libstdc++-$(apt list libstdc++6 2>/dev/null | grep -Eos '[0-9]+\.[0-9]+\.[0-9]+' | head -1 | cut -d . -f 1)-dev \
              lld \
              make \
              ninja-build \
              python3-dev \
              texinfo \
              u-boot-tools \
              xz-utils \
              zlib1g-dev
  ```

* ### Fedora

  ```
  dnf install bc \
              binutils-devel \
              bison \
              ccache \
              clang \
              cmake \
              elfutils-libelf-devel \
              flex \
              gcc \
              gcc-c++ \
              git \
              lld \
              make \
              ninja-build \
              openssl-devel \
              python3 \
              texinfo-tex \
              uboot-tools \
              xz \
              zlib-devel
  ```

* ### Arch Linux / Manjaro

  ```
  pacman -S base-devel \
            bc \
            bison \
            ccache \
            clang \
            cpio \
            cmake \
            flex \
            git \
            libelf \
            lld \
            llvm \
            ninja \
            openssl \
            python3 \
            uboot-tools
  ```

* ### Clear Linux

  ```
  swupd bundle-add c-basic \
                   ccache \
                   curl \
                   dev-utils \
                   devpkg-elfutils \
                   devpkg-openssl \
                   git \
                   python3-basic \
                   which
  ```

  Additionally, to build PowerPC kernels, you will need to build the U-Boot tools because there is no distribution package. The U-Boot tarballs can be found [here](https://ftp.denx.de/pub/u-boot/) and they can be built and used like so:

  ```
  $ curl -LSs https://ftp.denx.de/pub/u-boot/u-boot-2021.01.tar.bz2 | tar -xjf -
  $ cd u-boot-2021.01
  $ make -j"$(nproc)" defconfig tools-all
  ...
  $ sudo install -Dm755 tools/mkimage /usr/local/bin/mkimage
  $ mkimage -V
  mkimage version 2021.01
  ```

  Lastly, Clear Linux has `${CC}`, `${CXX}`, `${CFLAGS}`, and `${CXXFLAGS}` in the environment, which messes with the heuristics of the script for selecting a compiler. By default, the script will attempt to use `clang` and `ld.lld` but the environment's value of `${CC}` and `${CXX}` is respected first so `gcc` and `g++` will be used. Clear Linux has optimized their `gcc` and `g++` so this is fine but if you would like to use `clang` and `clang++` instead, invoke the script like so:

  ```
  $ CC=clang CFLAGS= CXX=clang++ CXXFLAGS= ./build-llvm.py ...
  ```


Python 3.5.3+ is recommended, as that is what the script has been tested against. These scripts should be distribution agnostic. Please feel free to add different distribution install commands here through a pull request.

## build-llvm.py

By default, `./build-llvm.py` will clone LLVM, grab the latest binutils tarball (for the LLVMgold.so plugin), and build LLVM, clang, and lld, and install them into `install`.

The script automatically clones and manages the [`llvm-project`](https://github.com/llvm/llvm-project). If you would like to do this management yourself, such as downloading a release tarball from [releases.llvm.org](https://releases.llvm.org/), doing a more aggressive shallow clone (versus what is done in the script via `--shallow-clone`), or doing a bisection of LLVM, you just need to make sure that your source is in an `llvm-project` folder within the root of this repository and pass `--no-update` into the script. See [this comment](https://github.com/ClangBuiltLinux/tc-build/issues/75#issuecomment-604374071) for an example.

Run `./build-llvm.py -h` for more options and information.

## build-binutils.py

This script builds a standalone copy of binutils. By default, `./build-binutils.py` will download the [latest stable version](https://www.gnu.org/software/binutils/) of binutils, build for all architectures we currently care about (see the help text or script for the full list), and install them into `install`. Run `./build-binutils.py -h` for more options.

Building a standalone copy of binutils might be needed because certain distributions like Arch Linux (whose options the script uses) might symlink `/usr/lib/LLVMgold.so` to `/usr/lib/bfd-plugins` ([source](https://bugs.archlinux.org/task/28479)), which can cause issues when using the system's linker for LTO (even with `LD_LIBRARY_PATH`):

```
bfd plugin: LLVM gold plugin has failed to create LTO module: Unknown attribute kind (60) (Producer: 'LLVM9.0.0svn' Reader: 'LLVM 7.0.1')
```

Having a standalone copy of binutils (ideally in the same folder at the LLVM toolchain so that only one `PATH` modification is needed) works around this without any adverse side effects. Another workaround is bind mounting the new `LLVMgold.so` to `/usr/lib/LLVMgold.so`.

## Contributing

This repository openly welcomes pull requests! There are a few presubmit checks that run to make sure the code stays consistently formatted and free of bugs.

1. All Python files must be passed through [`yapf`](https://github.com/google/yapf). See the installation section for how to get it (it may also be available through your package manager).

2. All shell files must be passed through [`shfmt`](https://github.com/mvdan/sh) (specifically `shfmt -ci -i 4 -w`) and emit no [`shellcheck`](https://github.com/koalaman/shellcheck) warnings.

The presubmit checks will do these things for you and fail if the code is not formatted properly or has a shellcheck warning. Running these tools on the command line before submitting will make it easier to get your code merged.

Additionally, please write a detailed commit message about why you are submitting your change.

## Getting help

Please open an issue on this repo and include your distribution, shell, the command you ran, and the error output.
