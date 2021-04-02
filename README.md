# Sapphire
Collection of PowerShell Tools

---VMware Horizon Tools---

VMware.VimAutomation.HorizonView and VMware.Hv.Helper are needed to use this module.

Due to how this module works add the HorizonView Module with a "Using" over an "Import"


EXAMPLE:
    
`Import-Module VMware.VimAutomation.HorizonView;

Import-Module VMware.Hv.Helper;

Using Module Sapphire.HorizonView;`

   
## HorizonView

FUNCTIONS:

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


STATIC METHODS:

**Class QueryData**

* QueryUsers
* QueryUsers_Get
* GetUsername
* QueryMachines
* QueryMachines_Get
* QueryDesktops
* QueryDesktops_Get
* QueryEntitled
* QueryEntitled_Get

	
