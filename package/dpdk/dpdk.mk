################################################################################
#
# DPDK
#
################################################################################

ifeq ($(BR2_DPDK_19_02),y)
DPDK_VERSION = 19.02
else
DPDK_VERSION = 18.11
endif

DPDK_SITE = http://dpdk.org/browse/dpdk/snapshot
DPDK_SOURCE = dpdk-$(DPDK_VERSION).tar.gz

DPDK_LICENSE = BSD-2c (core), GPLv2 (Linux drivers)
DPDK_LICENSE_FILES = GNUmakefile LICENSE.GPL
DPDK_INSTALL_STAGING = YES
DPDK_DEPENDENCIES += numactl

DPDK_ARCH_CONFIG = $(call qstrip,$(BR2_PACKAGE_DPDK_ARCH_CONFIG))

ifeq ($(BR2_PACKAGE_LIBPCAP),y)
DPDK_DEPENDENCIES += libpcap
endif

ifeq ($(BR2_SHARED_LIBS),y)
define DPDK_ENABLE_SHARED_LIBS
  $(call KCONFIG_ENABLE_OPT,CONFIG_RTE_BUILD_SHARED_LIB,\
      $(@D)/build/.config)
endef
DPDK_POST_CONFIGURE_HOOKS = DPDK_ENABLE_SHARED_LIBS
endif

ifeq ($(BR2_PACKAGE_DPDK_KERNEL_MODULES),y)
LINUX_NEEDS_MODULES = y
DPDK_DEPENDENCIES += linux
DPDK_KERNEL_MODULES_MAKE_ARGS += \
	RTE_KERNELDIR=$(LINUX_DIR)
else
DPDK_KERNEL_MODULES_MAKE_ARGS += \
	CONFIG_RTE_KNI_KMOD=n \
	CONFIG_RTE_EAL_IGB_UIO=n
endif # BR2_PACKAGE_DPDK_KERNEL_MODULES

define DPDK_CONFIGURE_CMDS
  $(TARGET_MAKE_ENV) $(MAKE) -C $(@D) T=$(DPDK_ARCH_CONFIG) $(DPDK_KERNEL_MODULES_MAKE_ARGS) \
		CROSS=$(TARGET_CROSS) config
endef

define DPDK_BUILD_CMDS
  $(TARGET_MAKE_ENV) $(MAKE) -C $(@D) $(DPDK_KERNEL_MODULES_MAKE_ARGS) CROSS=$(TARGET_CROSS)
  $(DPDK_EXAMPLES_BUILD_CMDS)
endef

define DPDK_INSTALL_STAGING_CMDS
  $(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) prefix=/usr \
		CROSS=$(TARGET_CROSS) install-sdk install-runtime
endef

define DPDK_INSTALL_TARGET_CMDS
  $(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) prefix=/usr \
    CROSS=$(TARGET_CROSS) install-runtime
endef

$(eval $(generic-package))
