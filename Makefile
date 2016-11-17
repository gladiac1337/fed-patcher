#
# FED-Patcher build Makefile
# 

NDK_TOOLCHAIN_TMP=/tmp/ndk-toolchain
BUSYBOX_PATH=busybox-1.25.1
BUSYBOX_DOTCONFIG_TEMPLATE=busybox.config
MKBOOTIMG_PATH=mkbootimg
SIGNAPK=sign-apk

CP = cp -p
JAVA = java
M4 = m4
MAKE = make
MKDIR = mkdir -p
PYTHON=python
RM = rm -f
ZIP = zip

all: create_flashable_zip

busybox_all: busybox_arm busybox_arm64 busybox_x86

mkbootimg_all: mkbootimg_arm mkbootimg_arm64 mkbootimg_x86

busybox_arm: ndk_arm
	$(MKDIR) build
	$(CP) -r $(BUSYBOX_PATH) build/$(BUSYBOX_PATH)-arm
	$(M4) -D_M4_CONFIG_CROSS_COMPILER_PREFIX="arm-linux-androideabi-" -D_M4_CONFIG_SYSROOT="$(NDK_TOOLCHAIN_TMP)-arm/sysroot" $(BUSYBOX_DOTCONFIG_TEMPLATE) > build/$(BUSYBOX_PATH)-arm/.config
	PATH="$(NDK_TOOLCHAIN_TMP)-arm/bin:$(PATH)" $(MAKE) -C build/$(BUSYBOX_PATH)-arm
	$(MKDIR) dist/busybox/arm
	$(CP) build/$(BUSYBOX_PATH)-arm/busybox dist/busybox/arm/

busybox_arm64: ndk_arm64
	$(MKDIR) build
	$(CP) -r $(BUSYBOX_PATH) build/$(BUSYBOX_PATH)-arm64
	$(M4) -D_M4_CONFIG_CROSS_COMPILER_PREFIX="aarch64-linux-android-" -D_M4_CONFIG_SYSROOT="$(NDK_TOOLCHAIN_TMP)-arm64/sysroot" $(BUSYBOX_DOTCONFIG_TEMPLATE) > build/$(BUSYBOX_PATH)-arm64/.config
	PATH="$(NDK_TOOLCHAIN_TMP)-arm64/bin:$(PATH)" $(MAKE) -C build/$(BUSYBOX_PATH)-arm64
	$(MKDIR) dist/busybox/arm64
	$(CP) build/$(BUSYBOX_PATH)-arm64/busybox dist/busybox/arm64/

busybox_x86: ndk_x86
	$(MKDIR) build
	$(CP) -r $(BUSYBOX_PATH) build/$(BUSYBOX_PATH)-x86
	$(M4) -D_M4_CONFIG_CROSS_COMPILER_PREFIX="i686-linux-android-" -D_M4_CONFIG_SYSROOT="$(NDK_TOOLCHAIN_TMP)-x86/sysroot" $(BUSYBOX_DOTCONFIG_TEMPLATE) > build/$(BUSYBOX_PATH)-x86/.config
	PATH="$(NDK_TOOLCHAIN_TMP)-x86/bin:$(PATH)" $(MAKE) -C build/$(BUSYBOX_PATH)-x86
	$(MKDIR) dist/busybox/x86
	$(CP) build/$(BUSYBOX_PATH)-x86/busybox dist/busybox/x86/

# broken: incompatible target
#busybox_x86_64: ndk_x86_64
#	$(MKDIR) build
#	$(CP) -r $(BUSYBOX_PATH) build/$(BUSYBOX_PATH)-x86_64
#	$(M4) -D_M4_CONFIG_CROSS_COMPILER_PREFIX="x86_64-linux-android-" -D_M4_CONFIG_SYSROOT="$(NDK_TOOLCHAIN_TMP)-x86_64/sysroot" $(BUSYBOX_DOTCONFIG_TEMPLATE) > build/$(BUSYBOX_PATH)-x86_64/.config
#	PATH="$(NDK_TOOLCHAIN_TMP)-x86_64/bin:$(PATH)" $(MAKE) -C build/$(BUSYBOX_PATH)-x86_64
#	$(MKDIR) dist/busybox/x86_64
#	$(CP) build/$(BUSYBOX_PATH)-x86_64/busybox dist/busybox/x86_64/

mkbootimg_arm: ndk_arm
	$(MKDIR) build
	$(CP) -r $(MKBOOTIMG_PATH) build/$(MKBOOTIMG_PATH)-arm
	CC="$(NDK_TOOLCHAIN_TMP)-arm/bin/arm-linux-androideabi-gcc" AR="$(NDK_TOOLCHAIN_TMP)-arm/bin/arm-linux-androideabi-ar rcv" $(MAKE) -C build/$(MKBOOTIMG_PATH)-arm all
	$(MKDIR) dist/mkbootimg/arm
	$(CP) build/$(MKBOOTIMG_PATH)-arm/mkbootimg build/$(MKBOOTIMG_PATH)-arm/unpackbootimg dist/mkbootimg/arm/

mkbootimg_arm64: ndk_arm64
	$(MKDIR) build
	$(CP) -r $(MKBOOTIMG_PATH) build/$(MKBOOTIMG_PATH)-arm64
	CC="$(NDK_TOOLCHAIN_TMP)-arm64/bin/aarch64-linux-android-gcc" AR="$(NDK_TOOLCHAIN_TMP)-arm64/bin/aarch64-linux-android-ar rcv" $(MAKE) -C build/$(MKBOOTIMG_PATH)-arm64 all
	$(MKDIR) dist/mkbootimg/arm64
	$(CP) build/$(MKBOOTIMG_PATH)-arm64/mkbootimg build/$(MKBOOTIMG_PATH)-arm64/unpackbootimg dist/mkbootimg/arm64/

mkbootimg_x86: ndk_x86
	$(MKDIR) build
	$(CP) -r $(MKBOOTIMG_PATH) build/$(MKBOOTIMG_PATH)-x86
	CC="$(NDK_TOOLCHAIN_TMP)-x86/bin/i686-linux-android-gcc" AR="$(NDK_TOOLCHAIN_TMP)-x86/bin/i686-linux-android-ar rcv" $(MAKE) -C build/$(MKBOOTIMG_PATH)-x86 all
	$(MKDIR) dist/mkbootimg/x86
	$(CP) build/$(MKBOOTIMG_PATH)-x86/mkbootimg build/$(MKBOOTIMG_PATH)-x86/unpackbootimg dist/mkbootimg/x86/

mkbootimg_x86_64: ndk_x86_64
	$(MKDIR) build
	$(CP) -r $(MKBOOTIMG_PATH) build/$(MKBOOTIMG_PATH)-x86_64
	CC="$(NDK_TOOLCHAIN_TMP)-x86_64/bin/x86_64-linux-android-gcc" AR="$(NDK_TOOLCHAIN_TMP)-x86_64/bin/x86_64-linux-android-ar rcv" $(MAKE) -C build/$(MKBOOTIMG_PATH)-x86_64 all
	$(MKDIR) dist/mkbootimg/x86_64
	$(CP) build/$(MKBOOTIMG_PATH)-x86_64/mkbootimg build/$(MKBOOTIMG_PATH)-x86_64/unpackbootimg dist/mkbootimg/x86_64/

create_flashable_zip: busybox_all mkbootimg_all
	$(CP) -r root/* dist/
	$(ZIP) -r fed-patcher.zip *
	$(JAVA) -jar $(SIGNAPK)/signapk.jar $(SIGNAPK)/certificate.pem $(SIGNAPK)/key.pk8 fed-patcher.zip fed-patcher_signed.zip

ndk_arm:
	@echo "Using NDK at $(NDK)"
	$(PYTHON) $(NDK)/build/tools/make_standalone_toolchain.py --force --arch arm --api 14 --install-dir $(NDK_TOOLCHAIN_TMP)-arm

ndk_arm64:
	@echo "Using NDK at $(NDK)"
	$(PYTHON) $(NDK)/build/tools/make_standalone_toolchain.py --force --arch arm64 --api 21 --install-dir $(NDK_TOOLCHAIN_TMP)-arm64

ndk_x86:
	@echo "Using NDK at $(NDK)"
	$(PYTHON) $(NDK)/build/tools/make_standalone_toolchain.py --force --arch x86 --api 14 --install-dir $(NDK_TOOLCHAIN_TMP)-x86

ndk_x86_64:
	@echo "Using NDK at $(NDK)"
	$(PYTHON) $(NDK)/build/tools/make_standalone_toolchain.py --force --arch x86_64 --api 21 --install-dir $(NDK_TOOLCHAIN_TMP)-x86_64

clean:
	$(RM) -r dist
	$(RM) -r build
	$(RM) -r $(NDK_TOOLCHAIN_TMP)-arm
	$(RM) -r $(NDK_TOOLCHAIN_TMP)-arm64
	$(RM) -r $(NDK_TOOLCHAIN_TMP)-x86
	$(RM) -r $(NDK_TOOLCHAIN_TMP)-x86_64

ifndef NDK
	$(error NDK is not defined! Please set the NDK environment variable)
endif
