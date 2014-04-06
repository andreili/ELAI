#!/bin/bash

readonly DEVICE_CB1=1
readonly DEVICE_CB2=2
readonly DEVICE_CB3=3

readonly TARGET_SD=1
readonly TARGET_NAND=2

readonly DISTR_GENTOO=1

readonly TMPFS_SIZE="500M"

readonly SERVER_ADDR="http://185.22.61.161/firmware/"
readonly BOOT_CB1="boot_CB1.tar.bz2"
readonly KERNEL_CB1="kernel_CB1.tar.bz2"

device=1
target=2
distr=1

screen_clear() {
	echo -en "\ec"
	echo -e "
		\e[0;36mCUBIEBOARD FLASHER\e[0m
		      \e[1;34mandreil\e[0m"
}

print_boards() {
	echo -e "
    Specify your device:
	1. Cubieboard 1
	2. Cubieboard 2 (don't supported)
	3. Cubieboard 3 (Cubietruck; don't supported)"
}

print_targets() {
	echo -e "
    Specify target:
	1. MicroSD
	2. NAND"
}

print_distrs() {
	echo -e "
    Specify OS:
	1. Gentoo"
}

print_menu() {
	screen_clear
	if [ $1 -eq 0 ]; then
	    print_boards
	elif [ $1 -eq 1 ]; then
		print_targets
	elif [ $1 -eq 2 ]; then
		print_distrs
	fi
}

choose() {
	if [ $1 -eq 0 ]; then
		read -p "Enter device number: " choose
	elif [ $1 -eq 1 ]; then
		read -p "Enter target number: " choose
	elif [ $1 -eq 2 ]; then
		read -p "Enter distributive number: " choose
	fi

	if ! [[ $choose =~ $re ]]; then
		choose $1
	fi
}

choose_device() {
	print_menu 0
	choose 0
	case $choose in
#		[1-3]*)
		1*)
			$device = $choose
			choose_target
			;;
		*)
			echo "Invalid choice!"
			;;
	esac
}

choose_target() {
	print_menu 1
	choose 1
	case $choose in
		[1-2]*)
			$target = $choose
			choose_distr
			;;
		*)
			echo "Invalid choice!"
			;;
	esac
}

choose_distr() {
	print_menu 2
	choose 2
	case $choose in
		[1-2]*)
			$distr = $choose
			install_prepare
			;;
		*)
			echo "Invalid choice!"
			;;
	esac
}

install_prepare() {
	screen_clear
	printf "\nPreparing to installation...\n"
	mount_tmpfs $TMPFS_SIZE
	
	if [ $device -eq $DEVICE_CB1 ]; then
		download_file "boot" $BOOT_CB1
		download_file "kernel" $KERNEL_CB1
	fi
	
	
	umount /mnt/tmpfs
}

mount_tmpfs() {
	printf "\tCreating RAM disk"
	mkdir -p /mnt/tmpfs
	mount -t tmpfs -o size=$1 tmpfs /mnt/tmpfs
	if [ $? -ne 0 ]; then
		printf "\e[1;31m\t[ERROR]\e[0m\n"
		exit 1
	fi
	printf "\e[32m\t[OK]\e[0m\n"
}

download_file() {
	printf "\tDowloading $1..."
	wget "$SERVER_ADDR$2" -O /mnt/tmpfs/$2 -q
	if [ $? -ne 0 ]; then
		printf "\e[1;31m\t[ERROR]\e[0m\n"
		exit 1
	fi
	printf "\e[32m\t[OK]\e[0m\n"
}

sdcard_prepare() {
	echo "1"
}

nand_prepare() {
	echo ":("
}

main() {
	re='^[0-9]+$'
	choose_device
}

main
