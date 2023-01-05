#!/bin/bash -e

# Directory contains the target rootfs
TARGET_ROOTFS_DIR="binary"

if [ -e $TARGET_ROOTFS_DIR ]; then
	sudo rm -rf $TARGET_ROOTFS_DIR
fi

case "${ARCH:-$1}" in
	arm|arm32|armhf)
		ARCH=armhf
		;;
	*)
		ARCH=arm64
		;;
esac

echo -e "\033[36m Building for $ARCH \033[0m"

if [ ! $VERSION ]; then
	VERSION="release"
fi

finish() {
	sudo umount $TARGET_ROOTFS_DIR/dev/pts
	sudo umount $TARGET_ROOTFS_DIR/dev
	sudo umount $TARGET_ROOTFS_DIR/sys
	sudo umount $TARGET_ROOTFS_DIR/proc
	exit -1
}
trap finish ERR

echo -e "\033[36m Extract image \033[0m"
sudo mkdir -p $TARGET_ROOTFS_DIR
sudo tar -C $TARGET_ROOTFS_DIR -xpf ubuntu-base-arm64.tar.gz

# overlay folder
sudo cp -rf overlay-ubuntu/* $TARGET_ROOTFS_DIR/

# overlay-firmware folder
sudo cp -rf overlay-firmware/* $TARGET_ROOTFS_DIR/

# ASUS: Change to copy all the kernel modules built from build.sh.
sudo cp -rf lib_modules/lib/modules $TARGET_ROOTFS_DIR/lib/

echo -e "\033[36m Change root.....................\033[0m"
if [ "$ARCH" == "armhf" ]; then
	sudo cp /usr/bin/qemu-arm-static $TARGET_ROOTFS_DIR/usr/bin/
elif [ "$ARCH" == "arm64"  ]; then
	sudo cp /usr/bin/qemu-aarch64-static $TARGET_ROOTFS_DIR/usr/bin/
fi

sudo mount -t proc /proc $TARGET_ROOTFS_DIR/proc
sudo mount -t sysfs /sys $TARGET_ROOTFS_DIR/sys
sudo mount -o bind /dev $TARGET_ROOTFS_DIR/dev
sudo mount -o bind /dev/pts $TARGET_ROOTFS_DIR/dev/pts

cat << EOF | sudo chroot $TARGET_ROOTFS_DIR

apt-get update

#-------ASUS customization start-------
echo $VERSION_NUMBER-$VERSION > /etc/version

apt upgrade -y
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confold" --force-yes -y install ubuntu-desktop-minimal \
    ubuntu-minimal

echo "# Let NetworkManager manage all devices on this system" > /etc/netplan/01-network-manager-all.yaml
echo "network:" >> /etc/netplan/01-network-manager-all.yaml
echo "  version: 2" >> /etc/netplan/01-network-manager-all.yaml
echo "  renderer: NetworkManager" >> /etc/netplan/01-network-manager-all.yaml

# Remove packages which are not needed.
apt autoremove -y

systemctl enable resize-helper.service
systemctl enable mountboot.service

echo tinkerboard2 > /etc/hostname
echo 127.0.0.1$'\t'tinkerboard2 >> /etc/hosts

rm -rf /var/lib/apt/lists/*
apt clean

#-------ASUS customization end-------

EOF

sudo umount $TARGET_ROOTFS_DIR/dev/pts
sudo umount $TARGET_ROOTFS_DIR/dev
sudo umount $TARGET_ROOTFS_DIR/sys
sudo umount $TARGET_ROOTFS_DIR/proc
