# Sapphire
Collection of PowerShell Tools

---VMware Horizon Tools---

VMware.VimAutomation.HorizonView and VMware.Hv.Helper are needed to use this module.</br>
Due to how this module works add the HorizonView Module with a "Using" over an "Import"</br>
  <p>
		EXAMPLE:</br>
    <b>
   		Import-Module VMware.VimAutomation.HorizonView;<br/>
    	Import-Module VMware.Hv.Helper;<br/>
    	Using Module Sapphire.HorizonView;<br/>
    </b>
  <p>
	<div>
	FUNCTIONS:
		<ul>
			<li>Add-AutoPoolMachine</li>
			<li>Convert-MachineIdToDesktopId</li>
			<li>Convert-MachineIdToUserId</li>
			<li>Convert-UserEntitlementIdToDesktopId</li>
			<li>ConvertFrom-DesktopId</li>
			<li>ConvertFrom-MachineId</li>
			<li>ConvertFrom-UserId</li>
			<li>Get-AutoPoolSize</li>
			<li>Get-MachineUser</li>
			<li>Get-MachineId</li>
			<li>Get-DesktopId</li>
			<li>Get-UserId</li>
			<li>Get-UserEntitlements</li>
			<li>Install-VMwareModules</li>
			<li>Pop-UserFromMachine</li>
			<li>Push-UserToMachine</li>
			<li>Resize-AutoPool</li>
			<li>Remove-AutoPoolMachine</li>
			<li>Search-UserInfo</li>
		</ul>
	</div>
	<div>
	STATIC METHODS:
		<div>
			Class QueryData:
			<ul>
				<li>QueryUsers</li>
				<li>QueryUsers_Get</li>
				<li>GetUsername</li>
				<li>QueryMachines</li>
				<li>QueryMachines_Get</li>
				<li>QueryDesktops</li>
				<li>QueryDesktops_Get</li>
				<li>QueryEntitled</li>
				<li>QueryEntitled_Get</li>
			</ul>
		</div>
	</div>
	
