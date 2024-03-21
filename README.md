# Sapphire
Collection of PowerShell Tools

**HorizonView**: Collection of VMware Horizon Tools

**PowerTools**: Binary that adds some functionality that I've found to be helpful.  


   
## HorizonView

### Overview

This is a script module for Vmware Horizon View automation.  Mostly quality of life funcitonality.  This is built off of VMware's already existing module.

VMware.VimAutomation.HorizonView and VMware.Hv.Helper are needed to use this module.

Due to how this module works add the HorizonView Module with a "Using" over an "Import"


EXAMPLE:
    
```pwsh
Import-Module VMware.VimAutomation.HorizonView;

Import-Module VMware.Hv.Helper;

Using Module Sapphire.HorizonView;
```

### Included Tools

**FUNCTIONS**

* Add-AutoPoolMachine
* Convert-MachineIdToDesktopId
* Convert-MachineIdToUserId
* Convert-UserEntitlementIdToDesktopId
* ConvertFrom-DesktopId
* ConvertFrom-MachineId
* ConvertFrom-UserId
* Get-AutoPoolSize
* Get-MachineUser
* Get-MachineId
* Get-DesktopId
* Get-UserId<
* Get-UserEntitlements
* Install-VMwareModules
* Pop-UserFromMachine
* Push-UserToMachine
* Resize-AutoPool
* Remove-AutoPoolMachine
* Search-UserInfo


**STATIC METHODS**

* *QueryData*
	* QueryUsers
	* QueryUsers_Get
	* GetUsername
	* QueryMachines
	* QueryMachines_Get
	* QueryDesktops
	* QueryDesktops_Get
	* QueryEntitled
	* QueryEntitled_Get


## PowerTools

### Overview 

This is a collection of miscellaneous PowerShell tools.

This binary module can be imported dirertly into PowerShell 

### Included Tools

**FUNCTIONS**

* ConvertFrom-Caesar

**Objects:**

* *ProcessHacker*
	* void WriteProcess(uint dwAddress, byte[] buffer)
	* void WriteInt16(uint dwAddress, Int16 val)
	* void WriteUInt16(uint dwAddress, UInt16 val)
	* void WriteInt32(uint dwAddress, Int32 val)
	* void WriteUInt32(uint dwAddress, UInt32 val)
	* void WriteInt64(uint dwAddress, Int64 val)
	* void WriteUInt64(uint dwAddress, UInt64 val)
	* void WriteFloat(uint dwAddress, float val)
	* void WriteDouble(uint dwAddress, double val)
	* void WriteASCII(uint dwAddress, string val)
	* byte[] ReadProcess(uint dwAddress, uint bytesToRead)
	* Int16 ReadInt16(uint dwAddress)
	* Int32 ReadInt32(uint dwAddress)
	* Int64 ReadInt64(uint dwAddress)
	* double ReadFloat(uint dwAddress)
	* double ReadDouble(uint dwAddress)
	* void Close()

