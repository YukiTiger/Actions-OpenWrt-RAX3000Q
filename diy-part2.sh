#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# 在编译前将你写好的 RAX3000Q 现代设备树和配置文件，用脚本注入到对应的目标目录中
mkdir -p target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/
# 假设你把重写好的现代 .dts 放在了你 Actions 仓库的根目录下
cp -f $GITHUB_WORKSPACE/ipq5018-cmcc-rax3000q.dts target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/

# 向新版 Makefile 动态追加设备声明
# 如果 ipq50xx.mk 里还没这段定义，可以用 echo 追加进去
if ! grep -q "define Device/cmcc_rax3000q" target/linux/qualcommax/image/ipq50xx.mk; then
cat << 'EOF' >> target/linux/qualcommax/image/ipq50xx.mk

define Device/cmcc_rax3000q
	$(call Device/FitImage)
	$(call Device/UbiFit)
	SOC := ipq5000
	DEVICE_VENDOR := CMCC
	DEVICE_MODEL := RAX3000Q
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	DEVICE_DTS_CONFIG := config@mp02.1
	IMAGES := nand-factory.ubi
	DEVICE_PACKAGES := ath11k-firmware-ipq5018 ath11k-firmware-qcn6122 kmod-ath11k-ahb kmod-ath11k-pci
enddefine
TARGET_DEVICES += cmcc_rax3000q
EOF
sed -i 's/enddefine/endef/g' target/linux/qualcommax/image/ipq50xx.mk
fi
