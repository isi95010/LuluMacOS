// Note:     This will NOT work without a hotpatch rename as follows: 
// Find:     5F4349440D41
// Replace:  584349440D41

DefinitionBlock ("", "SSDT", 2, "sqrl", "snya", 0x00000000)
{
    External (_SB_.PCI0, DeviceObj)
    External (_SB_.PCI0.I2C0, DeviceObj)
    External (_SB_.PCI0.I2C0.STPA, DeviceObj)
    
    Scope (_SB.PCI0.I2C0.STPA)
    {
        Name (_CID, "PNP0C50")  // _CID: Compatible ID
    }
}
