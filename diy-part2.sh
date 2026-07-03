#!/bin/bash
set -e  # 遇到错误立即退出

# 确保 DTS 文件存在并复制到正确位置
mkdir -p target/linux/qualcommax/dts/
cp -f $GITHUB_WORKSPACE/ipq5000-rax3000q.dts target/linux/qualcommax/dts/

# 同时复制到内核编译时需要的路径（这在 feeds install 后会自动处理）
cp -f $GITHUB_WORKSPACE/ipq5000-rax3000q.dts target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/
# 但为了更加可靠，建议在这里也添加对内核源码的引用

# 确保设备树会被编译进内核配置
if ! grep -q "CONFIG_ARCH_IPQXXX" .config 2>/dev/null; then
    # 可以在这里添加设备树相关配置
    :
fi

# 向 ipq50xx.mk 追加设备定义（如果不存在）
if ! grep -q "define Device/cmcc_rax3000q" target/linux/qualcommax/image/ipq50xx.mk; then
cat << 'EOF' >> target/linux/qualcommax/image/ipq50xx.mk

define Device/cmcc_rax3000q
	$(call Device/FitImage)
	$(call Device/UbiFit)
	SOC := ipq50xx
	DEVICE_VENDOR := CMCC
	DEVICE_MODEL := RAX3000Q
	DEVICE_DTS := ipq5000-rax3000q
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	IMAGES := nand-factory.ubi
	DEVICE_PACKAGES := kmod-ath11k-ahb kmod-ath11k-pci ath11k-firmware
endef
TARGET_DEVICES += cmcc_rax3000q
EOF
fi
