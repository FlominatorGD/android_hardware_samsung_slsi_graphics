# Copyright (C) 2012 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

LOCAL_PATH:= $(call my-dir)

ifndef TARGET_SOC_BASE
	TARGET_SOC_BASE := $(TARGET_SOC)
endif

COMMON_SHARED_LIBRARIES := liblog libcutils libutils libsync libexynosgscaler libion

COMMON_HEADER_LIBRARIES := libhardware_headers libcutils_headers libbinder_headers libexynos_headers

COMMON_C_INCLUDES := \
    $(TOP)/hardware/samsung_slsi/$(TARGET_SOC_BASE)/include \
    $(TOP)/hardware/samsung_slsi/exynos5/include \
    $(TOP)/hardware/samsung_slsi/graphics/base/include \
    $(TOP)/hardware/samsung_slsi/graphics/base/libhwc1_legacy \
    $(TOP)/hardware/samsung_slsi/graphics/base/libhwc1_legacy/libhwcutils \
    $(TOP)/hardware/samsung_slsi/graphics/$(TARGET_SOC_BASE)/libhwcmodule \
    $(TOP)/hardware/samsung_slsi/graphics/$(TARGET_SOC_BASE)/libdisplaymodule \
    $(TOP)/hardware/samsung_slsi/graphics/$(TARGET_SOC_BASE)/libhwcutilsmodule \
    $(TOP)/hardware/samsung_slsi/graphics/base/libmpp

COMMON_C_INCLUDES += $(TOP)/hardware/samsung_slsi/graphics/base/libhwc1_legacy/libdisplay

ifeq ($(BOARD_HDMI_INCAPABLE), true)
COMMON_C_INCLUDES += $(TOP)/hardware/samsung_slsi/graphics/base/libhwc1_legacy/libhdmi_dummy
else ifeq ($(BOARD_HDMI_LEGACY), true)
COMMON_C_INCLUDES += $(TOP)/hardware/samsung_slsi/graphics/base/libhwc1_legacy/libhdmi_legacy
else
COMMON_C_INCLUDES += $(TOP)/hardware/samsung_slsi/graphics/base/libhwc1_legacy/libvpphdmi
endif

ifeq ($(BOARD_USES_VIRTUAL_DISPLAY), true)

COMMON_C_INCLUDES += \
    $(TOP)/hardware/samsung_slsi/graphics/base/libhwc1_legacy/libvirtualdisplay

COMMON_C_INCLUDES += \
    $(TOP)/hardware/samsung_slsi/graphics/$(TARGET_SOC_BASE)/libvirtualdisplaymodule	
endif

COMMON_CFLAGS := -Wno-unused-parameter -Wno-unused-function
COMMON_CFLAGS += -DHLOG_CODE=0

ifeq ($(BOARD_DISABLE_HWC_DEBUG), true)
	COMMON_CFLAGS += -DDISABLE_HWC_DEBUG
endif

ifeq ($(BOARD_USES_LEGACY_SCALER), true)
       COMMON_CFLAGS += -DUSES_LEGACY_SCALER
endif

ifeq ($(BOARD_USES_VENDORIMAGE), true)
COMMON_PROPRIETARY_MODULE := true
endif

############################## libhwcService ##############################

ifeq ($(BOARD_USES_HWC_SERVICES),true)
include $(CLEAR_VARS)

LOCAL_PRELINK_MODULE := false
LOCAL_SHARED_LIBRARIES := $(COMMON_SHARED_LIBRARIES) \
    libbinder libhdmi libhwcutils libexynosgscaler libexynosdisplay
ifeq ($(BOARD_USES_VIRTUAL_DISPLAY), true)
LOCAL_SHARED_LIBRARIES += libvirtualdisplay
endif
LOCAL_HEADER_LIBRARIES := $(COMMON_HEADER_LIBRARIES)

LOCAL_CFLAGS := $(COMMON_CFLAGS)
LOCAL_CFLAGS += -DLOG_TAG=\"HWCService\"

LOCAL_C_INCLUDES := $(COMMON_C_INCLUDES)

LOCAL_SRC_FILES := \
    libhwcService/ExynosHWCService.cpp \
    libhwcService/IExynosHWC.cpp

LOCAL_MODULE := libExynosHWCService
LOCAL_MODULE_TAGS := optional
LOCAL_PROPRIETARY_MODULE := $(COMMON_PROPRIETARY_MODULE)

include $(TOP)/hardware/samsung_slsi/exynos/BoardConfigCFlags.mk
include $(BUILD_SHARED_LIBRARY)

endif

############################## libvirtualdisplay ##############################
include $(CLEAR_VARS)

LOCAL_PRELINK_MODULE := false
LOCAL_SHARED_LIBRARIES := $(COMMON_SHARED_LIBRARIES) \
    libexynosv4l2 libhwcutils libexynosdisplay libmpp
LOCAL_HEADER_LIBRARIES := $(COMMON_HEADER_LIBRARIES)


LOCAL_CFLAGS := $(COMMON_CFLAGS)
LOCAL_CFLAGS += -DLOG_TAG=\"virtual\"
LOCAL_CFLAGS += -DHLOG_CODE=3

LOCAL_C_INCLUDES := $(COMMON_C_INCLUDES)

LOCAL_C_INCLUDES += $(TOP)/hardware/samsung_slsi/graphics/base/libhwc1_legacy/libhdmi_legacy

ifeq ($(BOARD_USES_HWC_SERVICES),true)
    LOCAL_C_INCLUDES += $(TOP)/hardware/samsung_slsi/graphics/base/libhwc1_legacy/libhwcService
endif

LOCAL_SRC_FILES := \
    libvirtualdisplay/ExynosVirtualDisplay.cpp

LOCAL_MODULE_TAGS := optional
LOCAL_PROPRIETARY_MODULE := $(COMMON_PROPRIETARY_MODULE)
LOCAL_MODULE := libvirtualdisplay

include $(TOP)/hardware/samsung_slsi/graphics/$(TARGET_SOC_BASE)/libvirtualdisplaymodule/Android.mk
include $(TOP)/hardware/samsung_slsi/exynos/BoardConfigCFlags.mk
include $(BUILD_SHARED_LIBRARY)

############################## libhdmi_dummy ##############################
ifeq ($(BOARD_HDMI_INCAPABLE), true)

include $(CLEAR_VARS)

LOCAL_PRELINK_MODULE := false
LOCAL_SHARED_LIBRARIES := $(COMMON_SHARED_LIBRARIES) \
    libhwcutils libexynosdisplay libmpp libexynosgscaler
LOCAL_HEADER_LIBRARIES := $(COMMON_HEADER_LIBRARIES)

LOCAL_CFLAGS := $(COMMON_CFLAGS)

LOCAL_C_INCLUDES := $(COMMON_C_INCLUDES)

LOCAL_SRC_FILES := \
	libhdmi_dummy/ExynosExternalDisplay.cpp

LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := libhdmi
LOCAL_PROPRIETARY_MODULE := $(COMMON_PROPRIETARY_MODULE)

include $(TOP)/hardware/samsung_slsi/exynos/BoardConfigCFlags.mk
include $(TOP)/hardware/samsung_slsi/graphics/$(TARGET_SOC_BASE)/libhdmimodule/Android.mk
include $(BUILD_SHARED_LIBRARY)

############################## libhdmi_legacy ##############################
else ifeq ($(BOARD_HDMI_LEGACY), true)

include $(CLEAR_VARS)

LOCAL_PRELINK_MODULE := false
LOCAL_SHARED_LIBRARIES := $(COMMON_SHARED_LIBRARIES) \
    libexynosutils libexynosv4l2 libhwcutils libexynosdisplay libmpp libion
LOCAL_HEADER_LIBRARIES := $(COMMON_HEADER_LIBRARIES)

LOCAL_CFLAGS := $(COMMON_CFLAGS)

LOCAL_C_INCLUDES := $(COMMON_C_INCLUDES)

LOCAL_SRC_FILES := \
        libhdmi_legacy/ExynosExternalDisplay.cpp

ifneq ($(filter 3.10, $(TARGET_LINUX_KERNEL_VERSION)),)
LOCAL_SRC_FILES += \
	libhdmi_legacy/dv_timings.c
LOCAL_CFLAGS += -DUSE_DV_TIMINGS
endif

ifeq ($(TARGET_BOARD_PLATFORM),exynos4)
	LOCAL_CFLAGS += -DNOT_USE_TRIPLE_BUFFER
endif

LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := libhdmi
LOCAL_PROPRIETARY_MODULE := $(COMMON_PROPRIETARY_MODULE)

include $(TOP)/hardware/samsung_slsi/exynos/BoardConfigCFlags.mk
include $(TOP)/hardware/samsung_slsi/graphics/$(TARGET_SOC_BASE)/libhdmimodule/Android.mk
include $(BUILD_SHARED_LIBRARY)
endif

############################## libhwcutils ##############################

include $(CLEAR_VARS)

LOCAL_PRELINK_MODULE := false
LOCAL_SHARED_LIBRARIES := $(COMMON_SHARED_LIBRARIES) \
    libmpp libexynosgscaler

LOCAL_HEADER_LIBRARIES := $(COMMON_HEADER_LIBRARIES)

LOCAL_CFLAGS := $(COMMON_CFLAGS)
LOCAL_CFLAGS += -DLOG_TAG=\"hwcutils\"


LOCAL_C_INCLUDES := $(COMMON_C_INCLUDES)

ifeq ($(BOARD_USES_FIMC), true)
        LOCAL_SHARED_LIBRARIES += libexynosfimc
else
        LOCAL_SHARED_LIBRARIES += libexynosgscaler
endif


LOCAL_SRC_FILES += \
	libhwcutils/ExynosHWCUtils.cpp

LOCAL_SRC_FILES += \
	libhwcutils/ExynosMPP.cpp

ifeq ($(BOARD_USES_VIRTUAL_DISPLAY), true)

LOCAL_C_INCLUDES += \
	$(LOCAL_PATH)/../libvirtualdisplay \
	$(TOP)/hardware/samsung_slsi/exynos/libfimg4x
LOCAL_SHARED_LIBRARIES += libfimg
LOCAL_SHARED_LIBRARIES += libMcClient
LOCAL_STATIC_LIBRARIES := libsecurepath
LOCAL_SRC_FILES += libhwcutils/ExynosG2DWrapper.cpp
endif

LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := libhwcutils

LOCAL_PROPRIETARY_MODULE := $(COMMON_PROPRIETARY_MODULE)

include $(TOP)/hardware/samsung_slsi/graphics/$(TARGET_SOC_BASE)/libhwcutilsmodule/Android.mk
include $(TOP)/hardware/samsung_slsi/exynos/BoardConfigCFlags.mk
include $(BUILD_SHARED_LIBRARY)

############################## libExynosDisplay_legacy ##############################

include $(CLEAR_VARS)

LOCAL_PRELINK_MODULE := false
LOCAL_SHARED_LIBRARIES := $(COMMON_SHARED_LIBRARIES) \
    libhwcutils libhardware libexynosgscaler
LOCAL_HEADER_LIBRARIES := $(COMMON_HEADER_LIBRARIES)

ifeq ($(BOARD_USES_FIMC), true)
LOCAL_SHARED_LIBRARIES += libexynosfimc
else
LOCAL_SHARED_LIBRARIES += libexynosgscaler
endif

LOCAL_CFLAGS := $(COMMON_CFLAGS)
LOCAL_C_INCLUDES := $(COMMON_C_INCLUDES)

LOCAL_SRC_FILES := \
	libdisplay/ExynosDisplay.cpp \
	libdisplay/ExynosOverlayDisplay.cpp

LOCAL_PROPRIETARY_MODULE := $(COMMON_PROPRIETARY_MODULE)

LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := libexynosdisplay

include $(TOP)/hardware/samsung_slsi/graphics/$(TARGET_SOC_BASE)/libdisplaymodule/Android.mk
include $(TOP)/hardware/samsung_slsi/exynos/BoardConfigCFlags.mk
include $(BUILD_SHARED_LIBRARY)
############################## hwcomposer.exynos5.so ##############################

# HAL module implemenation, not prelinked and stored in
# hw/<COPYPIX_HARDWARE_MODULE_ID>.<ro.product.board>.so

ifneq ($(BOARD_DISABLE_HWC_DEBUG),true)
include $(CLEAR_VARS)
LOCAL_SRC_FILES := ExynosHWCDebug.c
LOCAL_MODULE := hwcdebug
include $(BUILD_EXECUTABLE)
endif

include $(CLEAR_VARS)

LOCAL_PRELINK_MODULE := false
LOCAL_MODULE_RELATIVE_PATH := hw
LOCAL_SHARED_LIBRARIES := $(COMMON_SHARED_LIBRARIES) \
    libhardware libhardware_legacy libhwcutils libexynosdisplay libhdmi libmpp libexynosgscaler libbfqio
ifeq ($(BOARD_USES_VIRTUAL_DISPLAY), true)
LOCAL_SHARED_LIBRARIES += libvirtualdisplay
endif
LOCAL_HEADER_LIBRARIES := $(COMMON_HEADER_LIBRARIES)

LOCAL_CFLAGS := $(COMMON_CFLAGS)
LOCAL_CFLAGS += -DLOG_TAG=\"hwcomposer\"

LOCAL_C_INCLUDES := $(COMMON_C_INCLUDES)
LOCAL_C_INCLUDES += \
	$(TOP)/hardware/samsung_slsi/graphics/$(TARGET_SOC_BASE)/libhdmimodule
ifeq ($(BOARD_USES_VIRTUAL_DISPLAY), true)
LOCAL_C_INCLUDES += \
	$(TOP)/hardware/samsung_slsi/graphics/$(TARGET_SOC_BASE)/libvirtualdisplaymodule
endif

ifeq ($(BOARD_USES_HWC_SERVICES),true)
	LOCAL_SHARED_LIBRARIES += libExynosHWCService
	LOCAL_C_INCLUDES += $(TOP)/hardware/samsung_slsi/graphics/base/libhwc1_legacy/libhwcService
endif

LOCAL_SRC_FILES := ExynosHWC.cpp

LOCAL_MODULE := hwcomposer.$(TARGET_BOOTLOADER_BOARD_NAME)
LOCAL_MODULE_TAGS := optional

LOCAL_PROPRIETARY_MODULE := $(COMMON_PROPRIETARY_MODULE)

include $(TOP)/hardware/samsung_slsi/exynos/BoardConfigCFlags.mk
include $(BUILD_SHARED_LIBRARY)
