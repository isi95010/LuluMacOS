# LuluMacOS
Tips for using MacOS on the Dell Chromebook 7310 (with Core i3 or i5 CPU)

**A complete EFI is not provided in this repo, in accordance with "DIY" tradition. DIY: Do It Yourself. You will be better familiar with the process and will be able to troubleshoot on your own by starting with the [Dortania OpenCore Install Guide](https://dortania.github.io/OpenCore-Install-Guide/config-laptop.plist/broadwell.html). Please do not request an EFI here.**

## Table of Contents
- [Current Status](#current-status)
- [Versions Tested](#versions-tested)
- [Requirements](#requirements)
- [Issues](#current-issues)
- [**Installation**](#installation)
   - [Required Steps](#these-steps-are-required-for-proper-functioning)
   - [Coreboot 4.20.0+ CPU patch](#Working-around-CPU-changes-to-Coreboot-4.20.0+)
   - [Suggested Kexts](#kexts)
   - [Suggested ACPI files and hotpatches](#acpi-folder)
- [Misc. Information](#misc-information)
## Current Status

| **Feature**        | **Status**           | **Notes**                                                                                     |
|--------------------|----------------------|-----------------------------------------------------------------------------------------------|
| WiFi               | Working              | Native with BCM94360NG. If you're using the stock card, see OpenIntelWireless (not covered)   |
| Bluetooth          | Working              | Native with BCM94360NG. If you're using the stock card, see OpenIntelWireless (not covered)   |
| Suspend / Sleep    | Working              |                                                                                               |
| Trackpad           | Working              | With `VoodooI2C.kext` and `VoodooRMI.kext` and ACPI patch.                                    | 
| Graphics Accel.    | Working              |                                                                                               |
| Internal Speakers  | Working              | AppleALC.kext using layout-id 3                                                               |
| Keyboard backlight | Working              | With [`SSDT-KBBL.aml`](https://github.com/isi95010/LuluMacOS/blob/main/acpi/SSDT-KBBL.dsl)    |           
| Keyboard & Remaps  | Working              | See remap ACPI sample [here](https://github.com/isi95010/LuluMacOS/blob/main/acpi/ssdt-chromebook-keys.dsl)                                   |
| SD Card Reader     | Working              | It is USB, so insert a card into the slot while USB mapping                                   |
| Headphone Jack     | Working              | AppleALC.kext using layout-id 3                                                               |
| HDMI Audio         | Working              |                                                                                               |
| HDMI Video         | Working              |                                                                                               |
| USB Ports          | Working              | Working with USB mapping                                                                      |
| Webcam             | Working              |                                                                                               |
| Internal Mic.      | Working              | AppleALC.kext using layout-id 3                                                               |
| Shutdown / Restart | Working              |                                                                                               |    
| Continuity         | Untested             | Will not work with stock Intel card. Should work with replacement BCM94360NG card             |    
| NVRAM              | Working              | Native NVRAM working with firmware 4.20 and 4.20.1. Earlier versions may need to emulate      |
                                                                          
--------------------------------------------------------------------------------------------------------------------------------------------------------
### Versions Tested

- 12 (Monterey)
- 10.14 (Mojave) 

--------------------------------------------------------------------------------------------------------------------------------------------------------

### Requirements

This document assumes you've already disabled write protect and successfuly flashed the [Chromeintosh fork](https://github.com/Chromeintosh/coreboot) of MrChromebox's  Coreboot firmware to your device.

- A Core i3 or Core i5 variant of the Dell Chromebook 7310. The Celeron version probably will _not_ work and is not covered at all.
- An external storage device (can range from an SD card to a USB Disk / Drive) for creating the installer USB.  
- Small philips screwdriver and "spudger" for opening the laptop chassis. This is to replace the tiny stock SSD (need at least a 64GB m.2 SATA) and optionally replacing the WiFi/BT card with a Broadcom-based unit. The BCM94360NG is highly recommended. 
- Experience with MacOS
- Experience with hackintoshes is preferable because this is even more niche than installing MacOS on a PC.
- A USB mouse in case you have trouble with the trackpad at first

### Current Issues
>**Note**: MrChromebox coreboot 4.20 (5/15/2023 release) and higher is confirmed to cause issues with booting macOS on Chromebooks without taking specific steps. There are several methods to work around this. See "4. Fixing CPU core (thread) definition and plugin-type" below
- Often, with the Dell 7310, booting MacOS seems to hang after IGPU initialization or somewhere around BlueTooth verbose messages. The trick is to just swipe or tap the trackpad and it should continue booting. 

## Installation

--------------------------------------------------------------------------------------------------------------------------------------------------------

# ***Warning:*** This is an advanced hobbyist project. There is no tech support and the authors of this document and authors of the documents linked are not responsible for damage to your device. Any claims about functionality may be opinion and are open to challenge. We will try to keep this guide up-to-date as new information emerges, but may become outdated at any point in the future. To discuss, feel free to post in the [Chrultrabook Forums](https://forum.chrultrabook.com/c/support/macos-support) or in the Hackintosh Paradise Discord server.
--------------------------------------------------------------------------------------------------------------------------------------------------------

### **These steps are **required** for proper functioning.**

1. If you haven't already, use Ethan's script to flash a MacOS-optimized build of UEFI coreboot after turning off hardware write protection using the [unplug battery method](https://docs.chrultrabook.com/docs/firmware/battery.html). This version of the firmware works in other OSes too, but has optimizations for MacOS which are still compatible with Windows and Linux.
2. Thoroughly read the [OpenCore Guide](https://dortania.github.io/OpenCore-Install-Guide/). Use [Laptop Broadwell](https://dortania.github.io/OpenCore-Install-Guide/config-laptop.plist/broadwell.html) when ready to set up your EFI. Be sure to use the Debug vesion of OpenCore initially.
   * See [here](https://dortania.github.io/OpenCore-Install-Guide/troubleshooting/debug.html) for OpenCore debugging info
   * Enable the SysReport quirk in order to dump your ACPI tables, especially your DSDT to run through SSDTTime to generate ***required SSDT's*** as mentioned in step 9. 
4. Re-visit this guide when you're done setting up your EFI. There are a few things we need to tweak to ensure our Chromebook works with macOS. 
5. Fixing CPU core (thread) definition and plugin-type as mentioned in Current Issues
* The simplest way: Flash using [Ethan's script](https://ethanthesleepy.one/macos/) instead of MrChromebox's.
* Advanced: In an SSDT, set _STA to 0 on all CPU threads, and then define new CPU thread names with compatible addressing and plugin-type set. See [4-thread CPU sample SSDT](https://github.com/isi95010/LuluMacOS/blob/main/acpi/ssdt-plug-4200.dsl) that you can compile and use. This assumes you're using MrChromebox Rom and not from Ethan's script.
* Advanced: (working for other Chromebook Hackintoshers): Use SSDT-Plug-Alt.aml. This seems to work fine, but leaves "stray" CPU definitions in the IOService plane. It is unknown if this can cause issues down the line but doesn't sit right with me. This assumes you're using MrChromebox Rom and not from Ethan's script.
* Advanced (works but not recommended): This is akin to static patching a DSDT, which hackintoshers have moved away from years ago. However, Coreboot defines the CPU in its own SSDT outside of the DSDT, usually called SSDT-1.aml. We can use OpenCore to drop (delete) this OEM SSDT and inject our own, mostly identical "SSDT-1" but with corrected CPU addressing and plugin-type within said SSDT or another SSDT. I won't provide instructions to do this. This assumes you're using MrChromebox Rom and not from Ethan's script.
6. In your `config.plist`, under `Booter -> Quirks` set `ProtectMemoryRegions` to `TRUE`. It should look something like this in your `config.plist` when done correctly:

   | Quirk                | Type | Value    |
   | -------------------- | ---- | -------- |
   | ProtectMemoryRegions | Boolean | True  |
   
   > **Warning** **The above must be enabled for Chromebooks/Chromeboxes to boot MacOS.**

7. Under `DeviceProperties -> Add -> PciRoot(0x0)/Pci(0x2,0x0)`, the following modifications are recommended to enable graphics acceleration, enable smooth LCD backlight stepping, correct the HDMI output signal type, and disable the nonexistant 3rd framebuffer: 
  
   | Key                      | Type   | Value    |
   | --------------------     | ----   | -------- |
   | AAPL,ig-platform-id      | data   | 06002616 |
   | framebuffer-patch-enable | data   | 01000000 |
   | framebuffer-con1-enable  | data   | 9B3E0000 |
   | framebuffer-con1-type    | data   | 00080000 |
   | framebuffer-portcount    | number | 2        |
   | enable-backlight-smoother| data   | 01000000 |
     
   > **You are free to experiment with different `AAPL,ig-platform-id`'s but 06002616 works well**
8. **`MacBookAir7,2` works with Mojave through Monterey. Anything before or after those MacOS versions is not covered here.**. You may find a better suited SMBIOS to mimic or for unsupported future OS versions. Experiment as you wish. 
9. You can use the standard VoodooPS2controller and VoodooPS2keyboard plugin with the [PS2 chromebook remapping SSDT sample](https://github.com/isi95010/LuluMacOS/blob/main/acpi/ssdt-chromebook-keys.dsl). There's no need to use a fork with custom maps in the kext. 
   - Keyboard backlight dimming works with `SSDT-KBBL.aml` and can be found [here](https://github.com/isi95010/LuluMacOS/blob/main/acpi/SSDT-KBBL.dsl). The light may or may not come back on after sleeping, but you can use the key-command to dim it back up... This is a bonus feature after all. 
10. It's recommended to use SSDTTime to generate a fake EC (laptop verions), HPET (IRQ conflicts) and PNLF (requred for display backlight control). Be sure to copy any resulting rename patches from `oc_patches.plist` into your `config.plist` under `ACPI -> Patch`. 
11. Map your USB ports³ before installing using Windows. If you can't be bothered to install Windows, mapping can be done in WinPE. See [USBToolbox](https://github.com/USBToolBox). Remember you need the USBToolbox.kext *and* your generated UTBMap.kext.    
12. Snapshot (cmd +r) or (ctrl + r) your `config.plist`. 

    > **Warning**: Don't use "clean snapshot" (`ctrl/cmd+shift+r`) in Propertree after initially copying the sample as config.plist. This can **wipe** some work. Only do *regular* snapshots after first starting. (`ctrl/cmd+r`)

13. Attempt to install the OS

> **Reminder**: In depth information about OpenCore can be found [here.](https://dortania.github.io/docs/latest/Configuration.html)

--------------------------------------------------------------------------------------------------------------------------------------------------------

### Working around CPU changes to Coreboot 4.20.0+ 
Coreboot UEFI firmware 4.20 (5/15/2023 release) has a known issue where booting macOS will hang even if you think you've created a plugin-type SSDT. To fix this, just use [Ethan's firmware script](https://ethanthesleepy.one/macos/) and the CPU address is solved, then you can use SSDTTime like the Dortania Guide suggests (but feed it SSDT-1.aml from your SysReport).

--------------------------------------------------------------------------------------------------------------------------------------------------------

### Kexts

Propertree *should* arrange the kexts in the correct order when using OC Snapshot, but here are the enabled kexts and how I've ordered them in my config.plist: 
```
Lilu.kext
VirtualSMC.kext
SMCBatteryManager.kext
SMCSuperIO.kext
SMCProcessor.kext
WhateverGreen.kext
AppleALC.kext
USBToolbox.kext
UTBMap.kext
VoodooPS2Controller.kext
VoodooPS2Keyboard.kext
VoodooPS2Trackpad.kext
VoodooRMI.kext
VoodooRMI.kext/VoodooInput.kext
VoodooI2C.kext/VoodooGPIO.kext
VoodooI2C.kext/VoodooI2CServices.kext
VoodooI2C.kext
VoodooRMI.kext/RMII2C.kext
```
Any kexts that are auto-loaded but not listed above should be disabled in your config.plist.

--------------------------------------------------------------------------------------------------------------------------------------------------------

### ACPI Folder

```
ssdt-plug-4200.aml
SSDT-EC.aml From SSDTTime. 
SSDT-HPET.aml From SSDTTime. (requires rename hotpatches, don't forget those)
SSDT-KBBL.aml
SSDT-PNLF.aml From SSDTTime. 
ssdt-syna.aml (requires hotpatch below)
ssdt-chromebook-keys.aml
```
**Note**: Some of these SSDTs were generated with [SSDTTime](https://github.com/corpnewt/SSDTTime) and some were manually written by me for *this specific* Chromebook. See the [ACPI Sample folder](https://github.com/isi95010/LuluMacOS/tree/main/acpi) for .dsl files you can download, double check, then compile into AML.
[ssdt-syna.aml](https://github.com/isi95010/LuluMacOS/blob/main/acpi/ssdt-syna.dsl) defines the _CID of the Synaptics RMI-I2C trackpad as `PNP0C50`. The original _CID in the DSDT is `ACPI0C50` so we need a hotpatch to rename _CID to XCID. This allows the new _CID in ssdt-syna.aml to work so that VoodooRMII2C can attach to the trackpad. one8three's method involves manually editing the plist of the kext. This method seems more suitable to survive kext updates down the line when you may forget about the _CID situation with the trackpad. Credit to one8three for identifying the discrepancy in the DSDT. Here is the hotpatch to put in the ACPI/Patch section of your config.plist: 
   | Key                  | Type   | Value              |
   | -------------------- | ------ | ------------------ |
   | Base                 | String |                    |
   | BaseSkip             | Number |    0               |
   | Comment              | String |_CID to XCID in SYNA|
   | Count                | Number |    0               |
   | Enabled              | Boolean|   True             |
   | Find                 | Data   |  5F4349440D41      |
   | Limit                | Number |    0               |
   | Mask                 | Data   |      <empty>       |
   | OemTableID           | Data   |    00000000        |
   | Replace              | Data   |  584349440D41      |
   | ReplaceMask          | Data   |      <empty>       |
   | Skip                 | Number |    0               |
   | TableLength          | Number |    0               |
   | TableSignature       | Data   |    00000000        |

--------------------------------------------------------------------------------------------------------------------------------------------------------

## Misc. Information

- When formatting the SSD in Disk Utility, make sure to toggle "Show all Drives" to start partitioning.
- Format the drive as `APFS` and `GUID Partition Table / GPT`
- Map your USB ports prior to installing macOS. You can use [USBToolBox](https://github.com/USBToolBox/tool) to do that. You *will* need a second kext that goes along with it for it to work. [Repo here.](https://github.com/USBToolBox/kext). Your UTBMap.kext will not work without USBToolBox.kext. 
- AppleTV and other DRM protected services may not work.
- Control keyboard light with left `ctrl` + left `alt` and `,` or `.`. 
    - `,` to decrease, `.` to increase.

* Credit to one8three for the original [Dell 7310 Guide](https://github.com/one8three/Hackintosh---Dell-Chromebook-13-7310)
* Credit to [mine-man30000](https://github.com/mine-man3000/macOS-Dragonair) for the guide this is based on
* Credit to [meghan06](https://github.com/meghan06/) for the guide that mine-man3000's is based on
* Credit to all those who contribute to the [Chrultrabook project](https://docs.chrultrabook.com)
* Credit to [MrChromebox](https://github.com/MrChromebox?tab=repositories) for inadvertently making the firmware compatible with MacOS.
* Credit to ExtremeXT for forking and including the modifications for a MacOS-friendly Coreboot
* Credit to Ethan (ethanthesleepyone) for hosting builds and the MacOS firmware script
