#!/bin/bash

# 确保 DTS 文件存在（假设仓库根目录有 ipq5000-rax3000q.dts）
mkdir -p target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/
cp -f $GITHUB_WORKSPACE/ipq5000-rax3000q.dts target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/

# 向 ipq50xx.mk 追加设备定义（如果不存在）
if ! grep -q "define Device/cmcc_rax3000q" target/linux/qualcommax/image/ipq50xx.mk; then
cat << 'EOF' >> target/linux/qualcommax/image/ipq50xx.mk

define Device/cmcc_rax3000q
	$(call Device/FitImage)
	$(call Device/UbiFit)
	SOC := ipq50xx
	DEVICE_VENDOR := CMCC
	DEVICE_MODEL := RAX3000Q
	DEVICE_DTS := ipq5000-rax3000q   # 明确指定 dts 文件名（不含路径）
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	# 去掉 DEVICE_DTS_CONFIG，除非你在 DTS 中定义了 config 节点
	IMAGES := nand-factory.ubi
	DEVICE_PACKAGES := kmod-ath11k-ahb kmod-ath11k-pci ath11k-firmware
endef
TARGET_DEVICES += cmcc_rax3000q
EOF
fi
