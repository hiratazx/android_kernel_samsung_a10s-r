# Rissu's Kernel Source for Samsung Galaxy A10s
> Based on Android 11 firmware.

### How to build ###

```bash
# Clone kernel repo
$ git clone https://github.com/rsuntk/android_kernel_samsung_a10s-r.git kernel-a10s
$ cd kernel-a10s

# See all defconfig
$ ls kernel/arch/arm64/configs

# Export the defconfig
$ export DEFCONFIG=yukiprjkt_defconfig

# Export LLVM path
$ export PATH=/home/$(whoami)/toolchains/clang-r428724/bin:$PATH

# Export CROSS_COMPILE path (aarch64-linux-android)
$ export CROSS_COMPILE=/home/$(whoami)/toolchains/aarch64-linux-android-4.9/bin/aarch64-linux-android-

# Build
$ bash build_kernel.sh
```

## Credits

- **2024 Rissu**
- **2024 Rissu Projects**
- **2024 yukiprjkt**
