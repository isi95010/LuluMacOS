// Gives keyboard backlight dimming on certain Chromebooks.  
// Commands: 
// Left Ctrl + Left Alt + , to decrease (comma) 
// Left Ctrl + Left Alt + . to increase (period) 

DefinitionBlock ("", "SSDT", 2, "sqrl", "KB-LED", 0x00000000)
{
    External (_SB_.PCI0.LPCB.EC0_.KBLV, UnknownObj)

    Device (KBBL)
    {
        Name (_UID, Zero)  // _UID: Unique ID
        Name (_HID, "GOOG000A")  // _HID: Hardware ID
        Method (KKCL, 0, NotSerialized)
        {
            Return (Package (0x07)
            {
                Zero, 
                0x07, 
                0x14, 
                0x23, 
                0x32, 
                0x4B, 
                0x64
            })
        }

        Method (KKCM, 1, NotSerialized)
        {
            \_SB.PCI0.LPCB.EC0.KBLV = Arg0
        }

        Method (KKQC, 0, NotSerialized)
        {
            Return (\_SB.PCI0.LPCB.EC0.KBLV) /* External reference */
        }
    }
}