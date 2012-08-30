#!/bin/sh
NDK_ROOT=~/dev/ndk
TOOLCHAIN_NAME=arm-linux-androideabi-4.4.3
TOOLCHAIN_ROOT=$NDK_ROOT/toolchains/$TOOLCHAIN_NAME
TOOLCHAIN_PREBUILD_ROOT=$TOOLCHAIN_ROOT/prebuilt/linux-x86
TOOLCHAIN_PREFIX=$TOOLCHAIN_PREBUILD_ROOT/bin/${TOOLCHAIN_NAME%-*}

NDK_PLATFORM_ROOT=$NDK_ROOT/platforms
TARGET_ARCH=arm
TARGET_ARCH_ABI=armeabi-v5te
TARGET_PLATFORM=android-8
SYSROOT=$NDK_PLATFORM_ROOT/$TARGET_PLATFORM/arch-$TARGET_ARCH

export PATH=$TOOLCHAIN_PREBUILD_ROOT/bin:$PATH

TARGET_NO_EXECUTE_CFLAGS="-Wa,--noexecstack"
TARGET_arm_release_CFLAGS="-O2 -fomit-frame-pointer -fstrict-aliasing -funswitch-loops -finline-limit=300"
TARGET_thumb_release_CFLAGS="-mthumb -Os -fomit-frame-pointer -fno-strict-aliasing -finline-limit=64"

TARGET_CPPFLAGS="-I$SYSROOT/usr/include"
TARGET_CFLAGS="$TARGET_CPPFLAGS -fpic -ffunction-sections -funwind-tables -fstack-protector -D__ARM_ARCH_5__ -D__ARM_ARCH_5T__ -D__ARM_ARCH_5E__ -D__ARM_ARCH_5TE__ -Wno-psabi $TARGET_NO_EXECUTE_CFLAGS"

if [[ "$TARGET_ARCH_ABI" == "armeabi-v7a" ]]
then
    TARGET_CFLAGS="$TARGET_CFLAGS -march=armv7-a -mfloat-abi=softfp -mfpu=vfp"
else
    TARGET_CFLAGS="$TARGET_CFLAGS -march=armv5te -mtune=xscale -msoft-float"
fi

TARGET_CFLAGS="$TARGET_CFLAGS $TARGET_thumb_release_CFLAGS"

TARGET_NO_UNDEFINED_LDFLAGS="-Wl,--no-undefined"
TARGET_NO_EXECUTE_LDFLAGS="-Wl,-z,noexecstack"

TARGET_LDFLAGS="-nostdlib $SYSROOT/usr/lib/libc.so $SYSROOT/usr/lib/libm.so $TARGET_NO_UNDEFINED_LDFLAGS $TARGET_NO_EXECUTE_CFLAGS -Wl,-rpath-link=$SYSROOT/usr/lib"
TARGET_LDLIBS="-lgcc"

FLAGS="--target-os=linux --cross-prefix=$TOOLCHAIN_PREFIX- --arch=arm --disable-armvfp"
FLAGS="$FLAGS --prefix=/home/laputa/local"
FLAGS="$FLAGS --enable-small --enable-postproc --enable-gpl --enable-static --enable-shared"
FLAGS="$FLAGS --disable-encoder=flac --disable-decoder=cavs --disable-protocols --disable-devices --disable-network --disable-hwaccels --disable-ffmpeg"

echo "configure with flags:"
echo $FLAGS --extra-cflags="$TARGET_CFLAGS" --extra-ldflags="$TARGET_LDFLAGS" --extra-libs="$TARGET_LDLIBS" | tee  info.txt
./configure $FLAGS --extra-cflags="$TARGET_CFLAGS" --extra-ldflags="$TARGET_LDFLAGS" --extra-libs="$TARGET_LDLIBS" | tee configuration.txt

