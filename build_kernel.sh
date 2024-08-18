#!/bin/bash

#
# Rissu's kernel build script.
#

#
# We decided to use clang-13, or known as clang-r428724 for compiling.
# Also, you can use clang-11/12 if you don't have it.
#

# COLORS SHEET
RED='\e[1;31m'
YELLOW='\e[1;33m'
NC='\e[0m'

pr_err() {
	echo -e "${RED}[E] $@${NC}";
	exit 1;
}
pr_warn() {
	echo -e "${YELLOW}[W] $@${NC}";
}
pr_info() {
	echo "[I] $@";
}


if [ -d /rsuntk ]; then
	pr_info "Rissu environment detected."
	export CROSS_COMPILE=/rsuntk/env/google/bin/aarch64-linux-android-
	export PATH=/rsuntk/env/clang-13/bin:$PATH
 	export DEFCONFIG="yukiprjkt_defconfig"
else
	if [ -z $PATH ]; then
		pr_err "Invalid empty variable for \$PATH"
	fi
	if [ -z $DEFCONFIG ]; then
		pr_warn "Empty variable for \$DEFCONFIG, using yukiprjkt_defconfig as default."
		DEFCONFIG="yukiprjkt_defconfig"
	fi
fi

# Now support FULL LLVM!
export LLVM=1
export CC=clang
export LD=ld.lld

# For LKM!
export KERNEL_OUT=$(pwd)/out

export ARCH=arm64
export ANDROID_MAJOR_VERSION=r
export PLATFORM_VERSION=11

export KCFLAGS=-w
export CONFIG_SECTION_MISMATCH_WARN_ONLY=y

DATE=$(date +'%Y%m%d%H%M%S')
IMAGE="$KERNEL_OUT/arch/$ARCH/boot/Image"
RES="$(pwd)/result"

# Build!

__mk_defconfig() {
	make -C $(pwd) --jobs $(nproc --all) O=$KERNEL_OUT LLVM=1 CC=clang LD=ld.lld KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y $DEFCONFIG
}
__mk_kernel() {
	make -C $(pwd) --jobs $(nproc --all) O=$KERNEL_OUT LLVM=1 CC=clang LD=ld.lld KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y
}

if [ ! -z $1 ]; then
	__mk_defconfig;
else
	mk_defconfig_kernel() {
		__mk_defconfig;
		__mk_kernel;
	}
fi

if [ -d $KERNEL_OUT ]; then
	pr_warn "An out/ folder detected, Do you wants dirty builds?"
	read -p "" OPT;
	
	if [ $OPT = 'y' ] || [ $OPT = 'Y' ]; then
		__mk_kernel;
	else
		rm -rR out;
		mk_defconfig_kernel;
	fi
else
	mk_defconfig_kernel;
fi

if [ -e $IMAGE ]; then
	echo "";
	pr_info "Build done."
	
	# printout Image properties
	echo "";
	pr_info "/proc/version:";
	strings $IMAGE | grep "Linux version";
	echo "";
	pr_info "Size (bytes):";
	du -b $IMAGE;
	echo "";
	# << BEGIN STRIPPING >> #

	KO="$KERNEL_OUT/lkms/connectivity"
	mkdir $RES
	mkdir -p $RES/kernel_modules
	
	mv $KERNEL_OUT/arch/$ARCH/boot/Image $RES

	strip() {
		llvm-strip --strip-unneeded $KO/$@
	}

	mv_xt() {
		mv $KO/$@ $RES/kernel_modules
	}

	pr_info "Stripping modules.."
	strip bt/mt66xx/legacy/bt_drv.ko
	strip common/wmt_drv.ko
	strip gps/gps_drv.ko
	strip fmradio/fmradio_drv.ko
	strip wlan/core/gen4m/wlan_drv_gen4m.ko
	strip wlan/adaptor/wmt_chrdev_wifi.ko
	pr_info "Stripped successfully!"
	
	mv_xt bt/mt66xx/legacy/bt_drv.ko
	mv_xt common/wmt_drv.ko
	mv_xt gps/gps_drv.ko
	mv_xt fmradio/fmradio_drv.ko
	mv_xt wlan/core/gen4m/wlan_drv_gen4m.ko
	mv_xt wlan/adaptor/wmt_chrdev_wifi.ko
	
	# unneccessary, but we gonna include it anyway.
	mv $KERNEL_OUT/kernel/kheaders.ko $RES/kernel_modules

	# zip it!
	zip_name="kernel-a10s_artifacts-`echo $DATE`.zip"
	cd result
	pr_info "Assembling build artifacts in zip file .."
	zip -6 -r "$zip_name" *
	cd ..
	mv $RES/$zip_name $(pwd)

	if [ -e $(pwd)/$zip_name ]; then
		pr_info "Zip created. file: $(pwd)/$zip_name"
		pr_info "Cleaning out/ dir .."
		rm -rR out -f;
		pr_info "Done!"
		if [ -d $RES ]; then
			pr_info "Cleaning result/ dir .."
			rm -rf $RES
		fi
	else
		pr_warn "Failed to create zip."
	fi
else
	pr_err "Build error."
fi
