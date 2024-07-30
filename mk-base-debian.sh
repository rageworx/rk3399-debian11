#!/bin/bash -e

RELEASE='bullseye'
ARCH='arm64'
TARGET='xfce'

ROOTFS_BASE_DIR="../rootfs-base"

if [ ! -e $ROOTFS_BASE_DIR ]; then
  ROOTFS_BASE_DIR="."
fi

if [ -e $ROOTFS_BASE_DIR/linaro-$RELEASE-alip-$ARCH-*.tar.gz ]; then
	rm $ROOTFS_BASE_DIR/linaro-$RELEASE-alip-$ARCH-*.tar.gz
fi

cd ubuntu-build-service/$RELEASE-$TARGET-$ARCH

echo -e "\033[36m Staring Download...... \033[0m"

make clean

./configure

make

if [ -e linaro-$RELEASE-alip-$ARCH-*.tar.gz ]; then
	sudo chmod 0666 linaro-$RELEASE-alip-$ARCH-*.tar.gz
	mv linaro-$RELEASE-alip-$ARCH-*.tar.gz ../../$ROOTFS_BASE_DIR/
else
	echo -e "\e[31m Failed to run livebuild, please check your network connection. \e[0m"
fi
