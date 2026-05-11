#!/bin/bash
export CROSS_COMPILE=/home/$USER/Android/Toolchains/aarch64-linux-gnu/bin/aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=/home/$USER/Android/Toolchains/arm-eabi/bin/arm-eabi-
export CLANG_TRIPLE=/home/$USER/Android/Toolchains/aarch64-elf/bin/aarch64-elf-
export CC=/home/$USER/Android/Toolchains/clang/bin/clang
export CLANG_TRIPLE=/home/$USER/Android/Toolchains/clang/bin/aarch64-linux-gnu-

ZIP_DIR="/home/$USER/Android/Kernel/Zip/"
ZIP_ALT_DIR="/home/$USER/Android/Kernel/Zip_Alt/"
CUR_DIR=$PWD

export ARCH=arm64
export PLATFORM_VERSION=11
export ANDROID_MAJOR_VERSION=s
export CONFIG_SECTION_MISMATCH_WARN_ONLY=y

function clean {
		printf "Cleaning\n"
		cd $CUR_DIR
		rm -rf vmlinux.* drivers/gator_5.27/gator_src_md5.h scripts/dtbtool_exynos/dtbtool arch/arm64/boot/dtb.img arch/arm64/boot/dts/exynos/*dtb* arch/arm64/configs/exynos9810_temp_defconfig
		make -j$(nproc) clean
		make -j$(nproc) mrproper
}

function patch {
		printf "Patching Cached Defconfig\n"
		sed -i 's/CONFIG_SECURITY_SELINUX_NEVER_ENFORCE=y/# CONFIG_SECURITY_SELINUX_NEVER_ENFORCE is not set/g' "$CUR_DIR"/.config
		sed -i 's/CONFIG_HALL_NEW_NODE=y/# CONFIG_HALL_NEW_NODE is not set/g' "$CUR_DIR"/.config
		sed -i 's/CONFIG_NETFILTER_XT_MATCH_OWNER=y/# CONFIG_NETFILTER_XT_MATCH_OWNER is not set/g' "$CUR_DIR"/.config
		sed -i 's/CONFIG_NETFILTER_XT_MATCH_L2TP=y/# CONFIG_NETFILTER_XT_MATCH_L2TP is not set/g' "$CUR_DIR"/.config
		sed -i 's/CONFIG_L2TP=y/# CONFIG_L2TP is not set/g' "$CUR_DIR"/.config
		sed -i 's/# CONFIG_NET_SCH_NETEM is not set/CONFIG_NET_SCH_NETEM=y/g' "$CUR_DIR"/.config
		sed -i 's/# CONFIG_NET_CLS_CGROUP is not set/CONFIG_NET_CLS_CGROUP=y/g' "$CUR_DIR"/.config
		sed -i 's/CONFIG_NET_CLS_BPF=y/# CONFIG_NET_CLS_BPF is not set/g' "$CUR_DIR"/.config
		sed -i 's/CONFIG_VSOCKETS=y/# CONFIG_VSOCKETS is not set/g' "$CUR_DIR"/.config
		sed -i 's/# CONFIG_CGROUP_NET_CLASSID is not set/CONFIG_CGROUP_NET_CLASSID=y/g' "$CUR_DIR"/.config
		echo "" >> "$CUR_DIR"/.config
		echo "CONFIG_TCP_CONG_LIA=y" >> "$CUR_DIR"/.config
		echo "CONFIG_TCP_CONG_OLIA=y" >> "$CUR_DIR"/.config
		echo "CONFIG_NETFILTER_XT_MATCH_QTAGUID=y" >> "$CUR_DIR"/.config
		echo "CONFIG_NETFILTER_XT_MATCH_ONESHOT=y" >> "$CUR_DIR"/.config
}

all="false"
clean="false"

if [ -d $ZIP_ALT_DIR ] 
then
    printf "Alternative Zip Exists\n" 
fi

if [ ! -d $ZIP_DIR ] 
then
    printf "Zip Folder DOESN'T Exists." 
fi

while getopts ":ca" flag; do
  case "${flag}" in
	c) clean='true' ;;
    a) all='true' ;;
  esac
done

if $clean
then
	clean
	exit 1
fi

if $all
then
	printf "Build Started\n"
	clean
	printf "Building G960\n"
	cp -vr $CUR_DIR/arch/arm64/configs/exynos9810_defconfig $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig
	echo "" >> $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig
	cat $CUR_DIR/arch/arm64/configs/exynos9810-starlte_defconfig >> $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig
	make exynos9810_temp_defconfig
	make -j$(nproc --all)
	cp -vr $CUR_DIR/arch/arm64/boot/Image $ZIP_DIR/Kernel/starlte/zImage
	cp -vr $CUR_DIR/arch/arm64/boot/dtb.img $ZIP_DIR/Kernel/starlte/dtb.img

if [ -d $ZIP_ALT_DIR ] 
then
    printf "Building G960 Alternative\n"
	cp -vr $CUR_DIR/arch/arm64/configs/exynos9810_defconfig $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig
	echo "" >> $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig
	cat $CUR_DIR/arch/arm64/configs/exynos9810-starlte_defconfig >> $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig
	make exynos9810_temp_defconfig
	patch
	make -j$(nproc --all)
	cp -vr $CUR_DIR/arch/arm64/boot/Image $ZIP_ALT_DIR/Kernel/starlte/zImage
	cp -vr $CUR_DIR/arch/arm64/boot/dtb.img $ZIP_ALT_DIR/Kernel/starlte/dtb.img
fi
	
	clean
	printf "Building N960\n"
	cp -vr $CUR_DIR/arch/arm64/configs/exynos9810_defconfig $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig
	echo "" >> $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig
	cat $CUR_DIR/arch/arm64/configs/exynos9810-crownlte_defconfig >> $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig
	make exynos9810_temp_defconfig
	make -j$(nproc --all)
	cp -vr $CUR_DIR/arch/arm64/boot/Image $ZIP_DIR/Kernel/crownlte/zImage
	cp -vr $CUR_DIR/arch/arm64/boot/dtb.img $ZIP_DIR/Kernel/crownlte/dtb.img
	
if [ -d $ZIP_ALT_DIR ] 
then
    printf "Building N960 Alternative\n"
	cp -vr $CUR_DIR/arch/arm64/configs/exynos9810_defconfig $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig
	echo "" >> $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig
	cat $CUR_DIR/arch/arm64/configs/exynos9810-crownlte_defconfig >> $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig
	make exynos9810_temp_defconfig
	patch
	make -j$(nproc --all)
	cp -vr $CUR_DIR/arch/arm64/boot/Image $ZIP_ALT_DIR/Kernel/crownlte/zImage
	cp -vr $CUR_DIR/arch/arm64/boot/dtb.img $ZIP_ALT_DIR/Kernel/crownlte/dtb.img
fi
	
	clean
fi
printf "Building G965\n"
cp -vr $CUR_DIR/arch/arm64/configs/exynos9810_defconfig $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig
echo "" >> $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig
cat $CUR_DIR/arch/arm64/configs/exynos9810-star2lte_defconfig >> $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig
make exynos9810_temp_defconfig
make -j$(nproc --all)
cp -vr $CUR_DIR/arch/arm64/boot/Image $ZIP_DIR/Kernel/star2lte/zImage
cp -vr $CUR_DIR/arch/arm64/boot/dtb.img $ZIP_DIR/Kernel/star2lte/dtb.img

if [ -d $ZIP_ALT_DIR ] 
then
printf "Building G965 Alternative\n"
cp -vr $CUR_DIR/arch/arm64/configs/exynos9810_defconfig $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig
echo "" >> $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig
cat $CUR_DIR/arch/arm64/configs/exynos9810-star2lte_defconfig >> $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig
make exynos9810_temp_defconfig
patch
make -j$(nproc --all)
cp -vr $CUR_DIR/arch/arm64/boot/Image $ZIP_ALT_DIR/Kernel/star2lte/zImage
cp -vr $CUR_DIR/arch/arm64/boot/dtb.img $ZIP_ALT_DIR/Kernel/star2lte/dtb.img
fi
