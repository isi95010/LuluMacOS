# LuluMacOS
Tips for using MacOS on the Dell Chromebook 7310

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
| HDMI Audio         | Untested             | To do                                                                                         |
| HDMI Video         | Working              | Working OOTB                                                                                  |
| USB Ports          | Working              | Working with USB mapping                                                                      |
| Webcam             | Working              | Working OOTB                                                                                  |
| Internal Mic.      | Working              | AppleALC.kext using layout-id 3                                                               |
| Logout / Lock      | Working              | Working OOTB.                                                                                 |
| Shutdown / Restart | Working              | Working with `ProtectMemoryRegions` set to true in `config.plist`. (Chromebook moment)        |    
| Continuity         | Untested             | Will not work with stock Intel card. Should work with replacement BCM94360NG card             |    
| NVRAM              | Working              | Native NVRAM working with firmware 4.20 and 4.20.1. Earlier versions may need to emulate      |
                                                                          
--------------------------------------------------------------------------------------------------------------------------------------------------------
### Versions Tested

- 12 (Monterey)
- 10.14 (Mojave) 

--------------------------------------------------------------------------------------------------------------------------------------------------------

### Requirements

This document assumes you've already successfuly flashed the MrChromebox firmware to your device. It does not cover flashing. Before you start, you'll need to have the following items to complete the process:

- An external storage device (can range from an SD card to a USB Disk / Drive) for creating the installer USB.  
- Small philips screwdriver and "spudger" for opening the chassis to replace the tiny stock SSD (need at least a 64GB m.2 SATA) and optionally replacing the WiFi/BT card with a Broadcom-based unit. The BCM94360NG is highly recommended. 
- Experience with MacOS
- Experience with hackintoshes is preferable because this is even more niche than installing MacOS on a PC.
- A USB mouse in case you have trouble with the trackpad at first

### Current Issues
>**Note**: MrChromebox coreboot 4.20 (5/15/2023 release) and higher is confirmed to cause issues with booting macOS on Chromebooks without taking specific steps. There are several methods to work around this. See "4. Fixing CPU core (thread) definition and plugin-type" below
- Often, with the Dell 7310, booting MacOS seems to hang after IGPU initialization or somewhere around BlueTooth verbose messages. The trick is to just swipe or tap the trackpad and it should continue booting. 

## Installation

--------------------------------------------------------------------------------------------------------------------------------------------------------

> **Warning** Pay _close_ attention to the Chromebook specific parts in the Dortania guide, specifically in `Booter -> Quirks` and the iGPU `boot-args`.

> **Warning** Pay _very_ close attention to the following steps, if you miss **even one**, your Chromebook will lose some functionally and might not even boot.
> **Warning** This is an advanced project. As such, there is no tech support and the authors of this document or documents linked are not responsible for damage to your device. 


--------------------------------------------------------------------------------------------------------------------------------------------------------

### **These steps are **required** for proper functioning.**

1. If you haven't already, flash your Chromebook with [MrChromebox's UEFI firmware](https://mrchromebox.tech) via his scripts. To complete this process, you must turn off hardware write protection using the WP screw.
2. Thoroughly read the [OpenCore Guide](https://dortania.github.io/OpenCore-Install-Guide/). Use [Laptop Broadwell](https://dortania.github.io/OpenCore-Install-Guide/config-laptop.plist/broadwell.html) when ready to set up your EFI. 
3. Re-visit this guide when you're done setting up your EFI. There are a few things we need to tweak to ensure our Chromebook works with macOS. 
4. Fixing CPU core (thread) definition and plugin-type as mentioned in Current Issues
* Method 1 (recommended by isi95010): In an SSDT, set _STA to 0 on all CPU threads, and then define new CPU thread names with compatible addressing and plugin-type set. See [4-thread CPU sample SSDT](https://github.com/isi95010/LuluMacOS/blob/main/acpi/ssdt-plug-4200.dsl) that you can compile and use. 
* Method 2 (working for other Chromebook Hackintoshers): Use SSDT-Plug-Alt.aml. This seems to work fine, but leaves "stray" CPU definitions in the IOService plane. It is unknown if this can cause issues down the line but doesn't sit right with me.
* Method 3 (works but not recommended): This is akin to static patching a DSDT, which hackintoshers have moved away from years ago. However, Coreboot defines the CPU in its own SSDT outside of the DSDT, usually called SSDT-1.aml. We can use OpenCore to drop (delete) this OEM SSDT and inject our own, mostly identical "SSDT-1" but with corrected CPU addressing and plugin-type within said SSDT or another SSDT. I won't provide instructions to do this. 
5. In your `config.plist`, under `Booter -> Quirks` set `ProtectMemoryRegions` to `TRUE`. It should look something like this in your `config.plist` when done correctly:

   | Quirk                | Type | Value    |
   | -------------------- | ---- | -------- |
   | ProtectMemoryRegions | Boolean | True  |
   
   > **Warning** **This must be enabled for Chromebooks/Chromeboxes.**

6. Under `DeviceProperties -> Add -> PciRoot(0x0)/Pci(0x2,0x0)`, the following modifications are recommended to enable graphics acceleration, enable smooth LCD backlight stepping, correct the HDMI output signal type, and disable the nonexistant 3rd framebuffer: 
  
   | Key                      | Type   | Value    |
   | --------------------     | ----   | -------- |
   | AAPL,ig-platform-id      | data   | 06002616 |
   | framebuffer-patch-enable | data   | 01000000 |
   | framebuffer-con1-enable  | data   | 9B3E0000 |
   | framebuffer-con1-type    | data   | 00080000 |
   | framebuffer-portcount    | number | 2        |
   | enable-backlight-smoother| data   | 01000000 |
     
   > **Warning** **These should be the only items `in PciRoot(0x0)/Pci(0x2,0x0)`.**
7. **`MacBookAir7,2` works with Mojave through Monterey. Anything before or after those MacOS versions is not covered here.**. You may find a better suited SMBIOS to mimic or for unsupported future OS versions. Experiment as you wish. 
8. You can use the standard VoodooPS2controller and VoodooPS2keyboard plugin with the [PS2 chromebook remapping SSDT sample](https://github.com/isi95010/LuluMacOS/blob/main/acpi/ssdt-chromebook-keys.dsl). 
   - Keyboard backlight works with `SSDT-KBBL.aml` and can be found [here](https://github.com/isi95010/LuluMacOS/blob/main/acpi/SSDT-KBBL.dsl).
9. You can use SSDTTime to generate a fake EC (laptop verions), HPET (IRQ conflicts) and PNLF (requred for display backlight control). Be sure to copy any resulting rename patches from `oc_patches.plist` into your `config.plist` under `ACPI -> Patch`. 
10. Map your USB ports³ before installing using Windows. If you can't be bothered to install Windows, mapping can be done in WinPE. See [USBToolbox](https://github.com/USBToolBox). Remember you need the USBToolbox.kext *and* your generated UTBMap.kext.    
11. Snapshot (cmd +r) or (ctrl + r) your `config.plist`. 

    > **Warning**: Don't use "clean snapshot" (`ctrl/cmd+shift+r`) in Propertree after initially copying the sample as config.plist. This can **wipe** some work. Only do *regular* snapshots after first starting. (`ctrl/cmd+r`)

12. Attempt to install the OS

> **Reminder**: In depth information about OpenCore can be found [here.](https://dortania.github.io/docs/latest/Configuration.html)

--------------------------------------------------------------------------------------------------------------------------------------------------------

### Working around CPU changes to Coreboot 4.20.0+ 
Coreboot firmware 4.20 (5/15/2023 release) has a known issue where booting macOS will hang even if you think you've created a plugin-type SSDT. To fix this, we'll use an SSDT to manually define them. Credits to [ExtremeXT](https://github.com/ExtremeXT) for the fix described in method #2, which inspired method #3 and was finally refined to method #1.
- Method 1 Rename the CPU threads while adding CPU addressing and plugin-type with [this SSDT](https://github.com/isi95010/LuluMacOS/blob/main/acpi/ssdt-plug-4200.dsl). 
- Method 2 [SSDT-PLUG-ALT](https://github.com/meghan06/croscorebootpatch).
- Method 3 (see ACPI>Delete patch)

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
