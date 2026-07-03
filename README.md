
Build Immortalwrt for CMCC RAX3000Q/QY using GitHub Actions

Kernel Version : 5.4-QSDK

- Support IPV6
- Support Wi-Fi NSS
- Support NAT NSS

Base from [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)

Get SSH: [GetSSH](https://hugo.utermux.dev/default/rax3000q-latest/)

UBoot: [UBoot](https://github.com/hzyitc/openwrt-redmi-ax3000/issues/73#issuecomment-2259591683) Set computer ip to:192.168.1.8, use LAN1 port.

## Changes from Upstream (相比上游仓库的改动)

This fork includes the following modifications from the original [kkstone/Actions-OpenWrt-RAX3000Q](https://github.com/kkstone/Actions-OpenWrt-RAX3000Q):

### Device Tree & Kernel Support
- **Updated Device Tree Files**: Ported and enhanced `ipq5018-cmcc-rax3000q.dts` (renamed to `ipq5000-rax3000q.dts`) for OpenWrt 25.12 compatibility
- **Complete Hardware Configuration**: 
  - Restored full network configuration (ESS instance, MAC0/MAC1)
  - MDIO bus configuration with QCA8337 PHY definitions
  - WiFi firmware configuration (q6_wcss_pd1/pd2)
  - LED/button GPIO configuration with pinctrl support
  - NAND flash partition layout alignment

### Build System Enhancements
- **Enhanced diy-part2.sh Script**: 
  - Improved device tree file handling and copying
  - Added configuration validation checks
  - Error handling with `set -e` for robust builds
- **DTS Path Corrections**: Fixed DTS file copy destination from `files/` to `dts/` directory
- **Makefile Updates**: Device declaration and build process improvements

### OpenWrt Configuration
- **Version 25.12 Optimization**:
  - Removed incompatible `luci-compat` package
  - Added necessary network and driver packages
  - Memory profile configuration (CONFIG_ATH11K_MEM_PROFILE_256M)
  - Updated status property conventions

### Additional Features
- Added `luci-app-cpufreq` for CPU frequency control
- Enhanced configuration options in `.config` for better device support
- Improved build automation workflow

These changes ensure better stability, hardware support, and compatibility with the latest OpenWrt 25.12 release for CMCC RAX3000Q devices.

## Acknowledgments

- [Microsoft](https://www.microsoft.com)
- [Microsoft Azure](https://azure.microsoft.com)
- [GitHub](https://github.com)
- [GitHub Actions](https://github.com/features/actions)
- [tmate](https://github.com/tmate-io/tmate)
- [mxschmitt/action-tmate](https://github.com/mxschmitt/action-tmate)
- [csexton/debugger-action](https://github.com/csexton/debugger-action)
- [Cisco](https://www.cisco.com/)
- [ImmortalWrt](https://github.com/kkstone/immortalwrt-ipq50xx)

## License

[MIT](https://github.com/P3TERX/Actions-OpenWrt/blob/main/LICENSE) © P3TERX 
