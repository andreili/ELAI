#! /bin/bash


##########
# From SD:
#	tar xjfO init_SD.tar.bz2 | dd of=/dev/mmcblk0 bs=1M
# From NAND:
#
##########

readonly IMAGE_NAME="./init_img"

echo "Select drive:
    1. MicroSD
    2. NAND"
read -p "Enter #: " drive

echo "Select board:
    1. Cubieboard 1
    2. Cubieboard 2(3)"
read -p "Enter #: " board

echo "Creating initial ramdisk..."
##find ./ramdisk/RAW -print0 | cpio --null -o --format=newc | gzip -9 > ./ramdisk/initramfs.cpio.gz
##mkimage -A arm -O linux -T ramdisk -n "LFS RootFS" -d ./ramdisk/initramfs.cpio.gz ./ramdisk/initramfs > /dev/null

if [ $drive -eq 1 ]; then
	echo "Preparing partition image..."
	# creating image file

	dd if=./init/SD/u-boot_CB1 of=$IMAGE_NAME bs=512 count=2000 &> /dev/null
	dd if=/dev/zero of=$IMAGE_NAME bs=512 count=40960 seek=2048 &> /dev/null
	# create partition on image file
	fdisk $IMAGE_NAME &> /dev/null << X
n
p
1
2048
+17M
t
c
a
1
w
X
	# mount partition on image file
	losetup --offset 1048576 /dev/loop0 $IMAGE_NAME
	mkfs.vfat /dev/loop0 > /dev/null
	mkdir .tmp
	mount /dev/loop0 .tmp
fi

echo "Copying files..."
cp ./init/SD/CB1/* .tmp/
if [ $board -eq 1 ]; then
	cp ./kernels/CB1/boot/* .tmp/
fi

if [ $drive -eq 1 ]; then
	# unmount partition
	umount .tmp
	losetup -d /dev/loop0
	rm -Rf .tmp
	echo "Creating image archive..."
	tar cjpf init_SD.tar.bz2 $IMAGE_NAME
	rm $IMAGE_NAME
fi
