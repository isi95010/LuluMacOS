# LuluMacOS
Tips for using MacOS on the Dell Chromebook 7310

## Table of Contents
- [Current Status](#current-status)
- [Versions Tested](#versions-tested)
- [Requirements](#requirements)
- [Issues](#current-issues)
- [**1. Installation**](#1-installation)
   - [Required Steps](#these-steps-are-required-for-proper-functioning)
   - [Fixing coreboot 4.2.0+](#fixing-coreboot-420)
   - [Suggested Kexts](#kexts)
   - [Suggested ACPI files and hotpatches](#acpi-folder)
- [Misc. Information](#misc-information)
## Current Status

| **Feature**        | **Status**           | **Notes**                                                                                     |
|--------------------|----------------------|-----------------------------------------------------------------------------------------------|
| WiFi               | Working              | If you're using the stock NGFF card, see OpenIntelWireless                                    |
| Bluetooth          | Working              | If you're using the stock NGFF card, see OpenIntelWireless.                                   |
| Suspend / Sleep    | Working              |                                                                                               |
| Trackpad           | Working              | With `VoodooI2C.kext` and `VoodooRMI.kext` and ACPI patch.                                    | 
| Graphics Accel.    | Working              |                                                                                               |
| Internal Speakers  | Working              | AppleALC.kext using layout-id 3                                                               |
| Keyboard backlight | Working              | With `SSDT-KBBl.aml`                                                                          |           
| Keyboard & Remaps  | Working              | See remap                                                                                     |
| SD Card Reader     | Working              |                                                                                               |
| Headphone Jack     | Working              | AppleALC.kext using layout-id 3                                                               |
| HDMI Audio         | Untested             | To do                                                                                         |
| HDMI Video         | Working              | Working OOTB                                                                                  |
| USB Ports          | Working              | Working with USB mapping                                                                      |
| Webcam             | Working              | Working OOTB                                                                                  |
| Internal Mic.      | Working              | AppleALC.kext using layout-id 3                                                               |
| Logout / Lock      | Working              | Working OOTB.                                                                                 |
| Shutdown / Restart | Working              | Working with `ProtectMemoryReigons` set to true in `config.plist`. (Chromebook moment)        |    
| Continuity         | Untestes             | Will not work with stock Intel card. Should work with replacement BCM card                    |    
                                                                          
--------------------------------------------------------------------------------------------------------------------------------------------------------
### Versions Tested

- 12 (Monterey)
- 10.14 (Mojave) 

--------------------------------------------------------------------------------------------------------------------------------------------------------

### Requirements

Before you start, you'll need to have the following items to complete the process:

- **An understanding that this process has the potential to damage and/or brick your device, potentially causing it to become inoperable.**
- An external storage device (can range from an SD card to a USB Disk / Drive) for creating the installer USB.  
- Small philips screwdriver and "spudger" for removing the hardware WP screw, replacing the stock SSD and optionall replacing the WiFi/BT card with a Broadcom unit.
- Experience with MacOS
- Experience with hackintoshes is preferable because this is even more niche than installing MacOS on a PC. 


### Current Issues
>**Note**: coreboot 4.20 (5/15/2023 release) and higher as of July 21 2023 is known to cause issues with booting macOS. There are several methods to work around this.
- Often, the OS seems to hang after IGPU initialization or at BlueTooth verbose messages. The trick is to just swipe or tap the trackpad and it'll continue.

## 1. Installation

Here are the steps to go from chromeOS to macOS via OpenCore on your Chromebook. 

--------------------------------------------------------------------------------------------------------------------------------------------------------

> **Warning** Pay _close_ attention to the Chromebook specific parts in the Dortania guide, specifically in `Booter -> Quirks` and the iGPU `boot-args`.

> **Warning** Pay _very_ close attention to the following steps, if you miss **even one**, your Chromebook will lose some functionally and might not even boot.


--------------------------------------------------------------------------------------------------------------------------------------------------------

### **These steps are **required** for proper functioning.**

1. If you haven't already, flash your Chromebook with [MrChromebox's UEFI firmware](https://mrchromebox.tech) via his scripts. To complete this process, you must turn off hardware write protection using the WP screw.
2. Setup your EFI folder using the [OpenCore Guide](https://dortania.github.io/OpenCore-Install-Guide/). Use [Laptop Broadwell](https://dortania.github.io/OpenCore-Install-Guide/config-laptop.plist/broadwell.html) for your `config.plist`. 
3. Re-visit this guide when you're done setting up your EFI. There are a few things we need to tweak to ensure our Chromebook works with macOS. Skipping these steps will result in a **very** broken hack.
4. Fixing CPU core (thread) definition and plugin-type
* Method 1 (recommended by isi95010): In an SSDT, set _STA to 0 on all CPU threads, and then define new CPU thread names with compatible addressing and plugin-type set. See [ACPI sample] that you can compile and use.
* Method 2 (working for other Chromebook Hackintoshers): Use [SSDT-Plug-Alt.aml]. This seems to work fine, but leaves "stray" CPU definitions in the IOService plane. It is unknown if this can cause issues down the line but doesn't sit right with me.
* Method 3 (works but not recommended): This is akin to static patching a DSDT, which we've moved on from years ago. However, since Coreboot defines the CPU in its own SSDT, usually called SSDT-1.aml, we can use OpenCore to drop (delete) this OEM SSDT and inject our own, mostly identical "SSDT-1" but with corrected CPU addressing and plugin-type within said SSDT or another SSDT. I won't provide instructions to do this. 
6. In your `config.plist`, under `Booter -> Quirks` set `ProtectMemoryRegions` to `TRUE`. It should look something like this in your `config.plist` when done correctly:

   | Quirk                | Type | Value    |
   | -------------------- | ---- | -------- |
   | ProtectMemoryRegions | Boolean | True  |
   
   > **Warning** **This must be enabled.**

7. Under `DeviceProperties -> Add -> PciRoot(0x0)/Pci(0x2,0x0)`, make the following modifications to enable graphics acceleration, enable smooth LCD backlight stepping, correct HDMI output, and disable the nonexistant 3rd framebuffer:
  
   | Key                      | Type   | Value    |
   | --------------------     | ----   | -------- |
   | AAPL,ig-platform-id      | data   | 06002616 |
   | framebuffer-patch-enable | data   | 01000000 |
   | framebuffer-con1-enable  | data   | 9B3E0000 |
   | framebuffer-con1-type    | data   | 00080000 |
   | framebuffer-portcount    | number | 2        |
   | enable-backlight-smoother| data   | 01000000 |
     
   > **Warning** **These should be the only items `in PciRoot(0x0)/Pci(0x2,0x0)`.**
9. If you haven't already, add `-igfxblr` and `-igfxnotelemetryload` to your `boot-args`, under `NVRAM -> Add -> 7C436110-AB2A-4BBB-A880-FE41995C9F82,`. Both are for iGPU support, **you will regret it if you don't add these.**
10. **`MacBookAir7,2` works with Mojave through Monterey. Anything before or after those is not covered here.**. You may find a better suited SMBIOS to mimic or for unsupported future OS versions. Experiment as you wish.
11. Use the standard VoodooPS2controller and VoodooPS2keyboard plugin with the [PS2 chromebook remapping SSDT sample]. 
   - Keyboard backlight works with `SSDT-KBBL.aml` and can be found [here](update).
12. Download corpnewt's SSDTTime, then launch it and select `FixHPET`. Next, select `'C'` for default, and drag the SSDT it generated (`SSDT-HPET.aml`) into your `ACPI` folder. Finally, copy the patches from `oc_patches.plist` into your `config.plist` under `ACPI -> Patch`. 

    > **Warning** Steps 11 and 12 are **required** for macOS to recognize the internal eMMC disk. 
    > **Note** If eMMMC isn't recognized in Disk Utility, you probably made a mistake in steps 11 and 12.

13. Map your USB ports³ before installing using Windows. If you can't be bothered to install Windows, mapping can be done in WinPE. See [USBToolbox](https://github.com/USBToolBox). Remember you need the USBToolbox.kext and your generated UTBMap.kext.    
14. Snapshot (cmd +r) or (ctrl + r) your `config.plist`. 

    > **Warning**: Don't use "clean snapshot" (`ctrl/cmd+shift+r`) in Propertree after initially copying the sample as config.plist. This can **wipe** some work. Only do *regular* snapshots after first starting. (`ctrl/cmd+r`)

15. Attempt to install the OS

> **Note**: In depth information about OpenCore can be found [here.](https://dortania.github.io/docs/latest/Configuration.html)

--------------------------------------------------------------------------------------------------------------------------------------------------------

### Fixing coreboot 4.20
coreboot 4.20 (5/15/2023 release) has a known issue where macOS will hang on boot due to coreboot not defining CPU cores by default. To fix this, we'll use an SSDT to manually define them. Credits to [ExtremeXT](https://github.com/ExtremeXT) for the fix described in method #2, which inspired method #3 and finally refined to method #1.
- Method 1
- Method 2 [SSDT-PLUG-ALT](https://github.com/meghan06/croscorebootpatch).
- Method 3 (see ACPI>Delete patch)

--------------------------------------------------------------------------------------------------------------------------------------------------------

### Kexts

```
Lilu.kext
AppleALC.kext
ECEnabler.kext
SMCBatteryManager.kext
SMCProcessor.kext
SMCSuperIO.kext
UTBMap.kext
USBToolBox.kext
VirtualSMC.kext
VoodooI2C.kext
VoodooRMI.kext
VoodooPS2Controller.kext
WhateverGreen.kext
```

--------------------------------------------------------------------------------------------------------------------------------------------------------

### ACPI Folder

```
SSDT-EC-USBX-LAPTOP.aml
SSDT-HPET.aml
SSDT-KBBL.aml
SSDT-PNLF.aml
SSDT-PLUG-ALT.aml
```
>**Note**: Some of these SSDTs were generated with [SSDTTime](https://github.com/corpnewt/SSDTTime) and some were manually written by me 

--------------------------------------------------------------------------------------------------------------------------------------------------------

## Misc. Information

- When formatting the eMMC drive in Disk Utility, make sure to toggle "Show all Drives" and erase the entire drive.
- Format the drive as `APFS` and `GUID Partition Table / GPT`
- Map your USB ports prior to installing macOS³ for a painless install. You **will** reget it if you don't. You can use [USBToolBox](https://github.com/USBToolBox/tool) to do that. You *will* need a second kext that goes along with it for it to work. [Repo here.](https://github.com/USBToolBox/kext). USBToolBox will not work without this kext. 
- AppleTV and other DRM protected services may not work.
- Control keyboard backlight with left `ctrl` + left `alt` and `<` `>`. 
    - `<` to decrease, `>` to increase.
- To fix  battery life, use CPUFriend to tweak power settings. 
- To hide the OpenCore boot menu, set `ShowPicker` to `False` in `Misc` ->` Boot` -> `ShowPicker`
- `AppleXcpmCfgLock` and `DisableIOMapper` can be enabled or disabled. There is no difference.
- eMMC will not be recognized if `ScanPolicy` is set to `0`.
>**Note**: SSDT-USB-Reset / SSDT-RHUB is not needed if using USBToolBox.

credit to [meghan06](https://github.com/meghan06/) for his guide which I based this one on. 
