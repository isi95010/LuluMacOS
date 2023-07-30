// SSDT for mapping top row keys on many chromebooks using MacOS

DefinitionBlock ("", "SSDT", 2, "sqrl", "cbkk", 0)
{
    External (_SB_.PCI0.PS2K, DeviceObj)
    
    Name(_SB.PCI0.PS2K.RMCF, Package()
    {
        "Keyboard", Package()
        {
            "Custom ADB Map", Package()
            {
                Package(){},
                "3b=4d",    // f1 to previous track
                "3c=42",    // f2 to next track
                "3d=34",    // f3 to play/pause
                "40=6b",    // f6 to display brightness down
                "41=71",    // f7 to display brightness up
                "42=4a",    // f8 to mute
                "43=49",    // f9 to volume down
                "44=48",    // f9 to volume up
            },
        },
    })
}
