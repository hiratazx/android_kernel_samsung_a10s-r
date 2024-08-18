#
# Rissu Projects (C) 2024
# Makefile for Mediatek LKM
# 
# Files under GPLv2 License
# Copyright(C) 2016 MediaTek Inc.
#

ifeq ($(CONFIG_BUILD_MTK_LKM),m)
BUILD_OPT = "loadable module"
endif
ifeq ($(CONFIG_BUILD_MTK_LKM),y)
BUILD_OPT = "inline"
endif

$(info [LKM]: Building as [${BUILD_OPT}])

TOP := $(srctree)
AUTOCONF_H := $(KERNEL_OUT)/include/generated/autoconf.h
TARGET_BUILD_VARIANT := user

export TOP AUTOCONF_H TARGET_BUILD_VARIANT

obj-$(CONFIG_BUILD_MTK_LKM) :=	\
	connectivity/bt/mt66xx/legacy/	\
	connectivity/common/	\
	connectivity/fmradio/	\
	connectivity/gps/	\
	connectivity/wlan/adaptor/	\
	connectivity/wlan/core/gen4m/

# ignore met_drv.ko or fpsgo.ko
#obj-$(CONFIG_BUILD_MTK_LKM) += met_drv_v2/
