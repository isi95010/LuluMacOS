// This is an SSDT example that can be used to re-apply CPU objects with plugin-type set to 1 when running MacOS.
// Note: your CPU may have more or less threads, so add or remove objects accordingly. This SSDT unmodified
// applies to a 4-thread CPU.

DefinitionBlock ("", "SSDT", 2, "sqrl", "plug4200", 0x00000000)
{
    // Make sure you define external references according to your stock ACPI tables.
    // With Coreboot, the CPU threads are likely defined in "SSDT-1.aml" and named 
    // starting with "CP00." This particular example applies to a 4 thread 
    // device running MrChromebox firmware version 4.20.
    
    External (_SB_, DeviceObj)
    External (_SB_.CP00, DeviceObj)
    External (_SB_.CP01, DeviceObj)
    External (_SB_.CP02, DeviceObj)
    External (_SB_.CP03, DeviceObj)
    
    Scope (\_SB) // Always double check your own ACPI tables to ensure examples SSDT's like this one apply.
    {
    
        Scope (CP00) // The original CPU thread, which was "Device (CP00)" in the original stock SSDT
        {
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin")) // This OS check ensures that you
                                     // don't hide your cpu in other 
                {                    // operating systems by mistake
                    Return (Zero)    // if you boot them through OpenCore
                }                       
                Else                  
                {
                    Return (0x0F)
                }
            }
        }
        Scope (CP01) // The next thread
        {
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (Zero)
                }
                Else
                {
                    Return (0x0F)
                }
            }
        }
        Scope (CP02) // And so on...
        {
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (Zero)
                }
                Else
                {
                    Return (0x0F)
                }
            }
        }
        Scope (CP03) // This is the fourth thread. 
        {
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (Zero)
                }
                Else
                {
                    Return (0x0F)
                }
            }
        }
                // More threads to hide? Continue with CP04, and so on. 
        
    
    // Next we define the CPU cores again under a different naming scheme. They can't be the same 
    // names as the originals that we have just "hidden" above with _STA methods. 
    
        Processor (CPU0, 0x00, 0x00000410, 0x06) // I went with CPUx, so the first thread will now be known 
                                                 // to MacOS as CPU0 instead of CP00
        {
            Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
            Name (_UID, Zero)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (_OSI ("Darwin")) // OS check on all the newly named threads
                                     // to make sure other OS's don't have 
                                     // extra conflicting CPU thread names. 
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                If ((Arg2 == Zero))          // This is the Plugin-Type part.
                {                            // This only needs to be on the 
                    Return (Buffer (One)     // first thread, which is CPU0 
                    {                        // in this example.
                         0x03                                             
                    })
                }

                Return (Package (0x02)
                {
                    "plugin-type", 
                    One
                })
            }
        }

        Processor (CPU1, 0x01, 0x00000410, 0x06)    // Keep going and define the rest of your threads. 
        {                                            
            Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
            Name (_UID, One)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }
        }

        Processor (CPU2, 0x02, 0x00000410, 0x06)
        {
            Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
            Name (_UID, 0x02)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }
        }

        Processor (CPU3, 0x03, 0x00000410, 0x06)    // Stop here if you have a 
        {                                           // 4-thread device.
            Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
            Name (_UID, 0x03)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }
        }
        // If you have more threads, continue defining them here with CPU4
    }
}
