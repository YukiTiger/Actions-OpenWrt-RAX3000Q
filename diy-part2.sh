#!/bin/bash
set -e  # Exit immediately on error

echo "[*] Setting up device tree and build configuration..."

# Create necessary directories
mkdir -p target/linux/qualcommax/dts/
mkdir -p target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/

# Copy DTS file to proper location for OpenWrt 25.12
echo "[*] Copying DTS file..."
cp -f $GITHUB_WORKSPACE/ipq5000-rax3000q.dts target/linux/qualcommax/dts/

# Verify base device tree exists
if [ -f "target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq5018.dtsi" ]; then
    echo "[+] Base ipq5018.dtsi found"
    # Check for required components
    echo "[*] Checking base DTB for required labels..."
    grep -q "&wifi0" target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq5018.dtsi && echo "[+] wifi0 found" || echo "[!] wifi0 not in base (may be defined elsewhere)"
    grep -q "&nand" target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq5018.dtsi && echo "[+] nand found" || echo "[!] nand not in base"
    grep -q "&dp1" target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq5018.dtsi && echo "[+] dp1/dp2 (MAC) found" || echo "[!] MAC nodes not in base"
else
    echo "[!] Warning: Base ipq5018.dtsi not found at expected location"
fi

# Add device definition to build system if not present
echo "[*] Checking device definition in ipq50xx.mk..."
if ! grep -q "define Device/cmcc_rax3000q" target/linux/qualcommax/image/ipq50xx.mk; then
    echo "[*] Adding cmcc_rax3000q device definition..."
    cat << 'EOF' >> target/linux/qualcommax/image/ipq50xx.mk

define Device/cmcc_rax3000q
	$(call Device/FitImage)
	$(call Device/UbiFit)
	SOC := ipq5018
	DEVICE_VENDOR := CMCC
	DEVICE_MODEL := RAX3000Q
	DEVICE_DTS_CONFIG := config@mp02.1
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	IMAGES := nand-factory.ubi
	DEVICE_PACKAGES := \
		ath11k-firmware-ipq5018 \
		ath11k-firmware-qcn6122 \
		ipq-wifi-cmcc_rax3000q
endef
TARGET_DEVICES += cmcc_rax3000q
EOF
    echo "[+] Device definition added"
else
    echo "[+] cmcc_rax3000q already defined"
fi

echo "[*] Device tree setup complete"
