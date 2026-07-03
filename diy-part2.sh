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

# Add WiFi calibration data patch for proper MAC address handling
echo "[*] Adding WiFi calibration data patch..."
mkdir -p patches/openwrt/

cat << 'EOF' > patches/openwrt/001-rax3000q-caldata.patch
From 0000000000000000000000000000000000000000 Mon Sep 17 00:00:00 2001
From: OpenWrt Builder <builder@example.com>
Date: Thu, 03 Jul 2026 00:00:00 +0800
Subject: [PATCH] qualcommax: ipq50xx: rax3000q: add caldata entries with MAC patching

Add proper calibration data extraction and MAC address handling for CMCC RAX3000Q.
The device requires:
- Calibration data extraction from ART partition
- MAC address patching (using label_mac + offset)
- Regdomain removal from calibration data
- Proper macflag setting for ath11k

This ensures stable WiFi operation with consistent MAC addresses across reboots.

---
 target/linux/qualcommax/ipq50xx/base-files/etc/hotplug.d/firmware/11-ath11k-caldata | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

--- a/target/linux/qualcommax/ipq50xx/base-files/etc/hotplug.d/firmware/11-ath11k-caldata
+++ b/target/linux/qualcommax/ipq50xx/base-files/etc/hotplug.d/firmware/11-ath11k-caldata
@@ -48,6 +48,13 @@ case "$FIRMWARE" in
 	xiaomi,ax6000)
 		caldata_extract "0:art" 0x1000 0x20000
 		;;
+	cmcc,rax3000q)
+		caldata_extract "0:art" 0x1000 0x20000
+		label_mac=$(mtd_get_mac_binary 0:art 0)
+		ath11k_patch_mac $(macaddr_add $label_mac 2) 0
+		ath11k_remove_regdomain
+		ath11k_set_macflag
+		;;
 	yuncore,ax830|\
 	yuncore,ax850)
 		caldata_extract "0:ART" 0x1000 0x20000
@@ -95,6 +102,13 @@ case "$FIRMWARE" in
 		ath11k_remove_regdomain
 		ath11k_set_macflag
 		;;
+	cmcc,rax3000q)
+		caldata_extract "0:art" 0x26800 0x20000
+		label_mac=$(mtd_get_mac_binary 0:art 0)
+		ath11k_patch_mac $(macaddr_add $label_mac 3) 0
+		ath11k_remove_regdomain
+		ath11k_set_macflag
+		;;
 	yuncore,ax830)
 		caldata_extract "0:ART" 0x4c000 0x20000
 		label_mac=$(mtd_get_mac_binary 0:ART 0)
EOF

echo "[+] WiFi calibration data patch created at patches/openwrt/001-rax3000q-caldata.patch"

echo "[*] Device tree setup complete"
