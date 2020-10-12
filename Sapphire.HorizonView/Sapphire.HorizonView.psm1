#PowerShell Module for VMware Horizon View 

#This Module requires the use of other VMware Modules (See Dependencies)
#Install-Module -Name VMware.VimAutomation.HorizonView;
#The VMware.Hv.Helper Module can be found here : https://github.com/vmware/PowerCLI-Example-Scripts/tree/master/Modules/VMware.Hv.Helper

#To Use this Module you will need to need to add a using statment to load custom objects
#---In Order words add this to the top of your script---#
#Using Module VMware.VimAutomation.HorizonView;
#Using Module VMware.Hv.Helper;
#Using Module Sapphire.HorizonView;
#-------------------------------------------------------#

###Dependencies###
#Import-Module VMware.VimAutomation.HorizonView;
#Import-Module VMware.Hv.Helper;
##################


#region Objects

class Sapphire_HorizonView_MachineInfo
{
    Sapphire_HorizonView_MachineInfo() #Default to null 
    {
        $this.MachineName = $NULL;
        $this.MachineId = New-Object VMware.Hv.EntityId;
        $this.DesktopName = $NULL;
        $this.DesktopId = New-Object VMware.Hv.EntityId;
        $this.Username = $NULL;
        $this.UserId = New-Object VMware.Hv.EntityId;
    }

    Sapphire_HorizonView_MachineInfo([string]$MachineName, [VMware.Hv.EntityId]$MachineId, [string]$DesktopName, [VMware.Hv.EntityId]$DesktopId, [string]$Username, [VMware.Hv.EntityId]$UserId)
    {
        $this.MachineName = $MachineName;
        $this.MachineId = $MachineId;
        $this.DesktopName = $DesktopName;
        $this.DesktopId = $DesktopId;
        $this.Username = $Username;
        $this.UserId = $UserId;
    }

    [string]$MachineName;
    [VMware.Hv.EntityId]$MachineId;
    [string]$DesktopName; #Desktop Pool
    [string]$Username;

    hidden [VMware.Hv.EntityId]$UserId;
    hidden [VMware.Hv.EntityId]$DesktopId;
}

class Sapphire_HorizonView_UserInfo
{
    Sapphire_HorizonView_UserInfo()
    {
        $this.Username = $NULL;
        $this.UserId = $NULL;
        $this.EmailAddress = $NULL;
    }

    Sapphire_HorizonView_UserInfo([string]$Username, [VMware.Hv.EntityId]$UserId, [string]$EmailAddress)
    {
        $this.Username = $Username;
        $this.UserId = $UserId;
        $this.EmailAddress = $EmailAddress;
    }

    [bool]IsValidEmail()
    {
        if ($this.EmailAddress.Length -gt 0)
        {
            if ($this.EmailAddress -match "^[a-zA-Z0-9.!f#$%&'^_~-`]+@[a-zA-Z0-9]+\.{1}([a-zA-Z0-9]+?)$")  #Email REGEX
            {
                return $true;
            }
            else
            {
                return $false;    
            }
        }
        else #Email address not set 
        {
            Write-Host "Email Address Not Found";
            return $false;    
        }
    }

    [string]$Username; #LoginName
    [string]$EmailAddress;
    [VMware.Hv.EntityId]$UserId;
}

class Sapphire_HorizonView_DesktopInfo
{
    Sapphire_HorizonView_DesktopInfo()
    {
        $this.DesktopName = $NULL;
        $this.DesktopId = New-Object VMware.Hv.EntityId;
        #$this.EntitledUsers = 0;
    }

    Sapphire_HorizonView_DesktopInfo([string]$DesktopName, [VMware.Hv.EntityId]$DesktopId)
    {
        $this.DesktopName = $DesktopName;
        $this.DesktopId = $DesktopId;
        #$this.EntitledUsers = $EntitledUsers;
    }

    #members
    [string]$DesktopName;
    [VMware.Hv.EntityId]$DesktopId;
    #[int]$EntitledUsers;
}

class Sapphire_HorizonView_EntitledInfo
{
    Sapphire_HorizonView_EntitledInfo()
    {
        $this.EntitledId = @();
        $this.Username = $NULL;
        $this.UserId = New-Object VMware.Hv.EntityId;
        $this.DesktopName = @();
        $this.DesktopId = New-Object VMware.Hv.EntityId;
    }

    Sapphire_HorizonView_EntitledInfo([VMware.Hv.EntityId[]]$EntitledId, [string]$Username, [VMware.Hv.EntityId]$UserId, [string]$DesktopName, [VMware.Hv.EntityId[]]$DesktopId)
    {
        $this.EntitledId = $EntitledId;
        $this.Username = $Username;
        $this.UserId = $UserId;
        $this.DesktopName = $DesktopName;
        $this.DesktopId = $DesktopId;
    }

    [VMware.Hv.EntityId[]]$EntitledId;
    [string]$Username;
    [string[]]$DesktopName;

    hidden [VMware.Hv.EntityId]$UserId;
    hidden [VMware.Hv.EntityId[]]$DesktopId;
}

class QueryData #static
{
    QueryData()
    {
        $this::UserInfo = New-Object Sapphire_HorizonView_UserInfo;
        $this::MachineInfo = New-Object Sapphire_HorizonView_MachineInfo;
        $this::DesktopInfo = New-Object Sapphire_HorizonView_DesktopInfo;
        $this::EntitledInfo = New-Object Sapphire_HorizonView_EntitledInfo;
    }

    <#hidden [void]setApiService([VMWare.Hv.Services]$apiService) #Manual set Vmware API service
    {
        $this::apiService = $apiService;
    }

    hidden [void]setApiService() #Same Code as Get-Api function, will probably intergrate the two together
    {
        if ($global:DefaultHVServers.Length -gt 0) #Use First HV Server
        {
            $this::apiService = $global:DefaultHVServers[0].ExtensionData;
            #return $global:DefaultHVServers[0].ExtensionData;
        }
        else #No HV Server Connection, setup new one
        {
            Write-Host "***Connect to View Horizon Server***" -ForegroundColor Cyan;
            [string]$Server = Read-Host -Prompt "Server Name";
            [string]$Domain = Read-Host -Prompt "Domain Name";

            $this::apiService = $(Connect-HVServer -Server $Server -Domain $Domain).ExtensionData;
        }
    }

    [VMware.Hv.Services]getApiServie()
    {
        if ($this::apiService -eq $NULL)
        {
            $this.setApiService();
        }

        return $this::apiService;
    }#>

    static [Sapphire_HorizonView_UserInfo[]]QueryUsers() #All to an extent, due to query limits some data will not be returned
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [VMware.Hv.QueryFilterEquals]$QueryFilter = New-Object VMware.Hv.QueryFilterEquals;
        [Object[]]$QueryResults = @();

        [VMware.Hv.Services]$apiService = Get-ApiService;

        [QueryData]::ClearUserQuery();

        $QueryDef.QueryEntityType = 'ADUserOrGroupSummaryView';
        $QueryDef.Limit = 2000; #Max limit is 2000, uses offsets if query is over 2000

        $QueryFilter.MemberName = 'base.group'; #Filter to only users
        $QueryFilter.Value = $false;  
        $QueryDef.Filter = $QueryFilter;

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;

        foreach($i in $QueryResults) 
        {
            [QueryData]::UserInfo += [Sapphire_HorizonView_UserInfo]::new($i.Base.LoginName.ToString(), $i.Id, $i.Base.Email);
        }   

        return [QueryData]::UserInfo;  
    }

    static [void]QueryUsers([switch]$NoRet) 
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [VMware.Hv.QueryFilterEquals]$QueryFilter = New-Object VMware.Hv.QueryFilterEquals;
        [Object[]]$QueryResults = @();

        [VMware.Hv.Services]$apiService = Get-ApiService;

        [QueryData]::ClearUserQuery();

        $QueryDef.QueryEntityType = 'ADUserOrGroupSummaryView';
        $QueryDef.Limit = 2000; #Max limit is 2000, uses offsets if query is over 2000

        $QueryFilter.MemberName = 'base.group'; #Filter to only users
        $QueryFilter.Value = $false;  
        $QueryDef.Filter = $QueryFilter;

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;

        foreach($i in $QueryResults) 
        {
            [QueryData]::UserInfo += [Sapphire_HorizonView_UserInfo]::new($i.Base.LoginName.ToString(), $i.Id, $i.Base.Email);
        }     
    }

    static [Sapphire_HorizonView_UserInfo[]]QueryUsers_Get() #This does not use touch stored queries
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [VMware.Hv.QueryFilterEquals]$QueryFilter = New-Object VMWare.Hv.QueryFilterEquals;
        [Object[]]$QueryResults = @();

        [Sapphire_HorizonView_UserInfo]$tempInfo = New-Object Sapphire_HorizonView_UserInfo;

        [VMware.Hv.Services]$apiService = Get-ApiService;

        $QueryDef.QueryEntityType = 'ADUserOrGroupSummaryView';
        $QueryDef.Limit = 2000; #Max limit is 2000, uses offsets if query is over 2000

        $QueryFilter.MemberName = 'base.group'; #Filter to only users
        $QueryFilter.Value = $false;  
        $QueryDef.Filter = $QueryFilter;

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;

        foreach($i in $QueryResults) 
        {
            $tempInfo += [Sapphire_HorizonView_UserInfo]::new($i.Base.LoginName.ToString(), $i.Id, $i.Base.Email);
        }   

        return $tempInfo;  
    }

    static [Sapphire_HorizonView_UserInfo[]]QueryUsers([string]$Filter)  #Search Based on Username 
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [VMware.Hv.QueryFilterContains]$QueryFilter = New-Object VMware.Hv.QueryFilterContains;
        [Object[]]$QueryResults = @();

        [VMware.Hv.Services]$apiService = Get-ApiService;

        [QueryData]::ClearUserQuery();

        $QueryDef.QueryEntityType = 'ADUserOrGroupSummaryView';
        $QueryDef.Limit = 2000;

        $QueryFilter.MemberName = 'base.loginName'; #Filter (Case sensitive)
        $QueryFilter.Value = $Filter;  
        $QueryDef.Filter = $QueryFilter;

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;

        foreach($i in $QueryResults) 
        {
            if (-not $i.Base.Group) #Use to filter only users 
            {                       
                [QueryData]::UserInfo += [Sapphire_HorizonView_UserInfo]::new($i.Base.LoginName.ToString(), $i.Id, $i.Base.Email);
            }
        }   

        return [QueryData]::UserInfo;
    }

    static [void]QueryUsers([string]$Filter, [switch]$NoRet)  #Search Based on Username 
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [VMware.Hv.QueryFilterContains]$QueryFilter = New-Object VMware.Hv.QueryFilterContains;
        [Object[]]$QueryResults = @();

        [VMware.Hv.Services]$apiService = Get-ApiService;

        [QueryData]::ClearUserQuery();

        $QueryDef.QueryEntityType = 'ADUserOrGroupSummaryView';
        $QueryDef.Limit = 2000;

        $QueryFilter.MemberName = 'base.loginName'; #Filter (Case sensitive)
        $QueryFilter.Value = $Filter;  
        $QueryDef.Filter = $QueryFilter;

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;

        foreach($i in $QueryResults) #return only user id and Username
        {
            if (-not $i.Base.Group)
            {
                [QueryData]::UserInfo += [Sapphire_HorizonView_UserInfo]::new($i.Base.LoginName.ToString(), $i.Id, $i.Base.Email);
            }
        }   
    }

    static [Sapphire_HorizonView_UserInfo[]]QueryUsers_Get([string]$Filter)  #Search Based on Username 
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [VMware.Hv.QueryFilterEquals]$QueryFilter = New-Object VMware.Hv.QueryFilterEquals;
        [Object[]]$QueryResults = @();

        [Sapphire_HorizonView_UserInfo[]]$tempInfo = @();

        [VMware.Hv.Services]$apiService = Get-ApiService;

        $QueryDef.QueryEntityType = 'ADUserOrGroupSummaryView';
        $QueryDef.Limit = 2000;

        $QueryFilter.MemberName = 'base.loginName'; #Filter (Case sensitive)
        $QueryFilter.Value = $Filter;  
        $QueryDef.Filter = $QueryFilter;

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results[0];

        foreach($i in $QueryResults) #return only user id and Username
        {
            if (-not $i.Base.Group)
            {
                $tempInfo += [Sapphire_HorizonView_UserInfo]::new($i.Base.LoginName.ToString(), $i.Id, $i.Base.Email);
            }
        }   

        return $tempInfo;
    }

    static [Sapphire_HorizonView_UserInfo[]]QueryUsers([string]$Filter, [string]$FilterTo) #Overload to filter results
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [VMware.Hv.QueryFilterContains]$QueryFilter = New-Object VMware.Hv.QueryFilterContains;
        [Object[]]$QueryResults = @();

        [VMware.Hv.Services]$apiService = Get-ApiService;

        [QueryData]::ClearUserQuery();

        $QueryDef.QueryEntityType = 'ADUserOrGroupSummaryView';
        $QueryDef.Limit = 2000;

        $QueryFilter.MemberName = $FilterTo; #Filter to What
        $QueryFilter.Value = $Filter;  
        $QueryDef.Filter = $QueryFilter; #Add Filter

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;

        foreach($i in $QueryResults) 
        {
            if (-not $i.Base.Group)
            {
                [QueryData]::UserInfo += [Sapphire_HorizonView_UserInfo]::new($i.Base.LoginName.ToString(), $i.Id, $i.Base.Email);
            }
        }   

        return [QueryData]::UserInfo;
    }

    static [void]QueryUsers([string]$Filter, [string]$FilterTo, [switch]$NoRet) #Overload to filter results
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [VMware.Hv.QueryFilterContains]$QueryFilter = New-Object VMware.Hv.QueryFilterContains;
        [Object[]]$QueryResults = @();

        [VMware.Hv.Services]$apiService = Get-ApiService;

        [QueryData]::ClearUserQuery();

        $QueryDef.QueryEntityType = 'ADUserOrGroupSummaryView';
        $QueryDef.Limit = 2000;

        $QueryFilter.MemberName = $FilterTo; #Filter to What
        $QueryFilter.Value = $Filter;  
        $QueryDef.Filter = $QueryFilter; #Add Filter

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;

        foreach($i in $QueryResults) 
        {
            if (-not $i.Base.Group)
            {
                [QueryData]::UserInfo += [Sapphire_HorizonView_UserInfo]::new($i.Base.LoginName.ToString(), $i.Id, $i.Base.Email);
            }
        }   
    }

    static [Sapphire_HorizonView_UserInfo[]]QueryUsers_Get([string]$Filter, [string]$FilterTo) #Overload to filter results
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [VMware.Hv.QueryFilterContains]$QueryFilter = New-Object VMware.Hv.QueryFilterContains;
        [Object[]]$QueryResults = @();

        [Sapphire_HorizonView_UserInfo[]]$tempInfo = @();

        [VMware.Hv.Services]$apiService = Get-ApiService;

        [QueryData]::ClearUserQuery();

        $QueryDef.QueryEntityType = 'ADUserOrGroupSummaryView';
        $QueryDef.Limit = 2000;

        $QueryFilter.MemberName = $FilterTo; #Filter to What
        $QueryFilter.Value = $Filter;  
        $QueryDef.Filter = $QueryFilter; #Add Filter

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;

        foreach($i in $QueryResults) 
        {
            if (-not $i.Base.Group)
            {
                $tempInfo += [Sapphire_HorizonView_UserInfo]::new($i.Base.LoginName.ToString(), $i.Id, $i.Base.Email);
            }
        }   

        return $tempInfo;
    }

    static [Sapphire_HorizonView_UserInfo]GetUsername([string]$Username)
    {
        [VMware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [VMware.Hv.QueryFilterEquals]$QueryFilter = New-Object VMware.Hv.QueryFilterEquals;
        [Object]$QueryResults = New-Object Object;

        [VMware.Hv.Services]$apiService = Get-ApiService;

        $QueryDef.QueryEntityType = 'ADUserOrGroupSummaryView';

        $QueryFilter.MemberName = 'base.loginName';
        $QueryFilter.Value = $Username;
        $QueryDef.Filter = $QueryFilter;

        try 
        {
            $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results[0];
        }
        catch #Catch All
        {
            Write-Host "Unable to Query User $($Username)";
            return $NULL;    
        }

        return [Sapphire_HorizonView_UserInfo]::new($QueryResults.Base.LoginName.ToString(), $QueryResults.Id, $QueryResults.Base.Email);
    }


    static [Sapphire_HorizonView_MachineInfo[]]QueryMachines()
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [Object[]]$QueryResults = @();

        [VMware.Hv.Services]$apiService = Get-ApiService;

        [QueryData]::ClearMachineQuery();

        $QueryDef.QueryEntityType = 'MachineSummaryView';
        $QueryDef.Limit = 2000;

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;

        foreach ($i in $QueryResults)
        {
            [Sapphire_HorizonView_MachineInfo]$tempInfo = New-Object Sapphire_HorizonView_MachineInfo;

            $tempInfo.MachineName = $i.Base.Name;
            $tempInfo.MachineId = $i.Id;
            $tempInfo.DesktopName = $i.Base.DesktopName;
            $tempInfo.DesktopId = $i.Base.Desktop;
            $tempInfo.UserId = $i.Base.User;

            if ($tempInfo.UserId.Length -gt 0)
            {
                $tempInfo.Username = $apiService.ADUserOrGroup.ADUserOrGroup_Get($tempInfo.UserId).Base.LoginName.ToString(); #Not returned in Query
            }

            [QueryData]::MachineInfo += $tempInfo;
        }

        return [QueryData]::MachineInfo;
    }

    static [void]QueryMachines([switch]$NoRet)
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [Object[]]$QueryResults = @();

        [VMware.Hv.Services]$apiService = Get-ApiService;

        [QueryData]::ClearMachineQuery();

        $QueryDef.QueryEntityType = 'MachineSummaryView';
        $QueryDef.Limit = 2000;

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;

        foreach ($i in $QueryResults)
        {
            [Sapphire_HorizonView_MachineInfo]$tempInfo = New-Object Sapphire_HorizonView_MachineInfo;

            $tempInfo.MachineName = $i.Base.Name;
            $tempInfo.MachineId = $i.Id;
            $tempInfo.DesktopName = $i.Base.DesktopName;
            $tempInfo.DesktopId = $i.Base.Desktop;
            $tempInfo.UserId = $i.Base.User;

            if ($tempInfo.UserId.Length -gt 0)
            {
                $tempInfo.Username = $apiService.ADUserOrGroup.ADUserOrGroup_Get($tempInfo.UserId).Base.LoginName.ToString(); #Not returned in Query
            }

            [QueryData]::MachineInfo += $tempInfo;
        }
    }

    static [Sapphire_HorizonView_MachineInfo[]]QueryMachines_Get()
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [Object[]]$QueryResults = @();

        [Sapphire_HorizonView_MachineInfo[]]$tempMachines = @(); #Store MachineInfo

        [VMware.Hv.Services]$apiService = Get-ApiService;

        $QueryDef.QueryEntityType = 'MachineSummaryView';
        $QueryDef.Limit = 2000;

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;

        foreach ($i in $QueryResults)
        {
            [Sapphire_HorizonView_MachineInfo]$tempInfo = New-Object Sapphire_HorizonView_MachineInfo;

            $tempInfo.MachineName = $i.Base.Name;
            $tempInfo.MachineId = $i.Id;
            $tempInfo.DesktopName = $i.Base.DesktopName;
            $tempInfo.DesktopId = $i.Base.Desktop;
            $tempInfo.UserId = $i.Base.User;

            if ($tempInfo.UserId.Length -gt 0)
            {
                $tempInfo.Username = $apiService.ADUserOrGroup.ADUserOrGroup_Get($tempInfo.UserId).Base.LoginName.ToString(); #Not returned in Query
            }

            $tempMachines += $tempInfo;
        }

        return $tempMachines;
    }

    static [Sapphire_HorizonView_MachineInfo[]]QueryMachines([string]$Filter, [string]$FilterTo)
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [VMware.Hv.QueryFilterContains]$QueryFilter = New-Object VMware.Hv.QueryFilterContains;
        [Object[]]$QueryResults = @();

        [VMware.Hv.Services]$apiService = Get-ApiService;

        [QueryData]::ClearMachineQuery();

        $QueryDef.QueryEntityType = 'MachineSummaryView';
        $QueryDef.Limit = 2000;

        $QueryFilter.MemberName = $FilterTo; #Filter to What
        $QueryFilter.Value = $Filter;  
        $QueryDef.Filter = $QueryFilter; #Add Filter

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;

        foreach ($i in $QueryResults)
        {
            [Sapphire_HorizonView_MachineInfo]$tempInfo = New-Object Sapphire_HorizonView_MachineInfo;

            $tempInfo.MachineName = $i.Base.Name;
            $tempInfo.MachineId = $i.Id;
            $tempInfo.DesktopName = $i.Base.DesktopName;
            $tempInfo.DesktopId = $i.Base.Desktop;
            $tempInfo.UserId = $i.Base.User;
            
            if ($tempInfo.UserId.Length -gt 0)
            {
                $tempInfo.Username = $apiService.ADUserOrGroup.ADUserOrGroup_Get($tempInfo.UserId).Base.LoginName.ToString(); #Not returned in Query
            }

            [QueryData]::MachineInfo += $tempInfo;
        }

        return [QueryData]::MachineInfo;
    }

    static [Sapphire_HorizonView_MachineInfo[]]QueryMachines([VMware.HV.EntityId]$Filter, [string]$FilterTo)
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [VMware.Hv.QueryFilterContains]$QueryFilter = New-Object VMware.Hv.QueryFilterContains;
        [Object[]]$QueryResults = @();

        [VMware.Hv.Services]$apiService = Get-ApiService;

        [QueryData]::ClearMachineQuery();

        $QueryDef.QueryEntityType = 'MachineSummaryView';
        $QueryDef.Limit = 2000;

        $QueryFilter.MemberName = $FilterTo; #Filter to What
        $QueryFilter.Value = $Filter;  
        $QueryDef.Filter = $QueryFilter; #Add Filter

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;

        foreach ($i in $QueryResults)
        {
            [Sapphire_HorizonView_MachineInfo]$tempInfo = New-Object Sapphire_HorizonView_MachineInfo;

            $tempInfo.MachineName = $i.Base.Name;
            $tempInfo.MachineId = $i.Id;
            $tempInfo.DesktopName = $i.Base.DesktopName;
            $tempInfo.DesktopId = $i.Base.Desktop;
            $tempInfo.UserId = $i.Base.User;
            
            if ($tempInfo.UserId.Length -gt 0)
            {
                $tempInfo.Username = $apiService.ADUserOrGroup.ADUserOrGroup_Get($tempInfo.UserId).Base.LoginName.ToString(); #Not returned in Query
            }

            [QueryData]::MachineInfo += $tempInfo;
        }

        return [QueryData]::MachineInfo;
    }

    static [void]QueryMachines([string]$Filter, [string]$FilterTo, [switch]$NoRet)
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [VMware.Hv.QueryFilterContains]$QueryFilter = New-Object VMware.Hv.QueryFilterContains;
        [Object[]]$QueryResults = @();

        [VMware.Hv.Services]$apiService = Get-ApiService;

        [QueryData]::ClearMachineQuery();

        $QueryDef.QueryEntityType = 'MachineSummaryView';
        $QueryDef.Limit = 2000;

        $QueryFilter.MemberName = $FilterTo; #Filter to What
        $QueryFilter.Value = $Filter;  
        $QueryDef.Filter = $QueryFilter; #Add Filter

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;

        foreach ($i in $QueryResults)
        {
            [Sapphire_HorizonView_MachineInfo]$tempInfo = New-Object Sapphire_HorizonView_MachineInfo;

            $tempInfo.MachineName = $i.Base.Name;
            $tempInfo.MachineId = $i.Id;
            $tempInfo.DesktopName = $i.Base.DesktopName;
            $tempInfo.DesktopId = $i.Base.Desktop;
            $tempInfo.UserId = $i.Base.User;
            
            if ($tempInfo.UserId.Length -gt 0)
            {
                $tempInfo.Username = $apiService.ADUserOrGroup.ADUserOrGroup_Get($tempInfo.UserId).Base.LoginName.ToString(); #Not returned in Query
            }

            [QueryData]::MachineInfo += $tempInfo;
        }
    }

    static [Sapphire_HorizonView_MachineInfo[]]QueryMachines_Get([string]$Filter, [string]$FilterTo)
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [VMware.Hv.QueryFilterContains]$QueryFilter = New-Object VMware.Hv.QueryFilterContains;
        [Object[]]$QueryResults = @();

        [Sapphire_HorizonView_MachineInfo[]]$tempMachines = @();

        [VMware.Hv.Services]$apiService = Get-ApiService;

        $QueryDef.QueryEntityType = 'MachineSummaryView';
        $QueryDef.Limit = 2000;

        $QueryFilter.MemberName = $FilterTo; #Filter to What
        $QueryFilter.Value = $Filter;  
        $QueryDef.Filter = $QueryFilter; #Add Filter

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;

        foreach ($i in $QueryResults)
        {
            [Sapphire_HorizonView_MachineInfo]$tempInfo = New-Object Sapphire_HorizonView_MachineInfo;

            $tempInfo.MachineName = $i.Base.Name;
            $tempInfo.MachineId = $i.Id;
            $tempInfo.DesktopName = $i.Base.DesktopName;
            $tempInfo.DesktopId = $i.Base.Desktop;
            $tempInfo.UserId = $i.Base.User;
            
            if ($tempInfo.UserId.Length -gt 0)
            {
                $tempInfo.Username = $apiService.ADUserOrGroup.ADUserOrGroup_Get($tempInfo.UserId).Base.LoginName.ToString(); #Not returned in Query
            }

            $tempMachines += $tempInfo;
        }

        return $tempMachines;
    }

    static [Sapphire_HorizonView_MachineInfo]GetMachine([string]$MachineName)
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [VMware.Hv.QueryFilterEquals]$QueryFilter = New-Object VMware.Hv.QueryFilterEquals;
        [Object]$QueryResults = @();

        [Sapphire_HorizonView_MachineInfo]$tempInfo = New-Object Sapphire_HorizonView_MachineInfo;

        [VMware.Hv.Services]$apiService = Get-ApiService;

        $QueryDef.QueryEntityType = 'MachineSummaryView';

        $QueryFilter.MemberName = 'base.name';
        $QueryFilter.Value = $MachineName;
        $QueryDef.Filter = $QueryFilter;

        try 
        {
            $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results[0];

            $tempInfo.MachineName = $QueryResults.Base.Name;
            $tempInfo.MachineId = $QueryResults.Id;
            $tempInfo.DesktopName = $QueryResults.Base.DesktopName;
            $tempInfo.DesktopId = $QueryResults.Base.Desktop;
            $tempInfo.UserId = $QueryResults.Base.User;
                
            if ($tempInfo.UserId.Length -gt 0)
            {
                $tempInfo.Username = $apiService.ADUserOrGroup.ADUserOrGroup_Get($tempInfo.UserId).Base.LoginName.ToString(); #Not returned in Query
            }
        }
        catch #All
        {
            Write-Host "Unable to Query Machine $($MachineName)";
        }

        return $tempInfo;
    }


    static [Sapphire_HorizonView_DesktopInfo[]]QueryDesktops()
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [Object[]]$QueryResults = @();

        [VMware.Hv.Services]$apiService = Get-ApiService;

        [QueryData]::ClearDesktopQuery();

        $QueryDef.QueryEntityType = 'DesktopSummaryView';
        $QueryDef.Limit = 2000;

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;

        foreach($i in $QueryResults)
        {
            [QueryData]::DesktopInfo += [Sapphire_HorizonView_DesktopInfo]::new($i.DesktopSummaryData.Name, $i.Id)
        }

        return [QueryData]::DesktopInfo;
    }

    static [void]QueryDesktops([switch]$NoRet)
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [Object[]]$QueryResults = $NULL;

        [VMware.Hv.Services]$apiService = Get-ApiService;

        [QueryData]::ClearDesktopQuery();

        $QueryDef.QueryEntityType = 'DesktopSummaryView';
        $QueryDef.Limit = 2000;

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;

        foreach($i in $QueryResults)
        {
            [QueryData]::DesktopInfo += [Sapphire_HorizonView_DesktopInfo]::new($i.DesktopSummaryData.Name, $i.Id)
        }
    }

    static [Sapphire_HorizonView_DesktopInfo[]]QueryDesktops_Get()
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [Object[]]$QueryResults = @();

        [Sapphire_HorizonView_DesktopInfo[]]$tempInfo = New-Object Sapphire_HorizonView_DesktopInfo;

        [VMware.Hv.Services]$apiService = Get-ApiService;

        [QueryData]::ClearDesktopQuery();

        $QueryDef.QueryEntityType = 'DesktopSummaryView';
        $QueryDef.Limit = 2000;

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;

        foreach($i in $QueryResults)
        {
            $tempInfo += [Sapphire_HorizonView_DesktopInfo]::new($i.DesktopSummaryData.Name, $i.Id)
        }

        return $tempInfo;
    }


    static [Sapphire_HorizonView_DesktopInfo[]]QueryDesktops([string]$Filter, [string]$FilterTo)
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [VMware.Hv.QueryFilterContains]$QueryFilter = New-Object VMware.Hv.QueryFilterContains;
        [Object[]]$QueryResults = @();

        [VMware.Hv.Services]$apiService = Get-ApiService;

        [QueryData]::ClearDesktopQuery();

        $QueryDef.QueryEntityType = 'DesktopSummaryView';
        $QueryDef.Limit = 2000;

        $QueryFilter.MemberName = $FilterTo; #Filter to What
        $QueryFilter.Value = $Filter;  
        $QueryDef.Filter = $QueryFilter; #Add Filter

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;

        foreach ($i in $QueryResults)
        {
            [QueryData]::DesktopInfo += [Sapphire_HorizonView_DesktopInfo]::new($i.DesktopSummaryData.Name, $i.Id);
        }

        return [QueryData]::DesktopInfo;
    }

    static [void]QueryDesktops([string]$Filter, [string]$FilterTo, [switch]$NoRet)
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [VMware.Hv.QueryFilterContains]$QueryFilter = New-Object VMware.Hv.QueryFilterContains;
        [Object[]]$QueryResults = @();

        [VMware.Hv.Services]$apiService = Get-ApiService;

        [QueryData]::ClearDesktopQuery();

        $QueryDef.QueryEntityType = 'DesktopSummaryView';
        $QueryDef.Limit = 2000;

        $QueryFilter.MemberName = $FilterTo; #Filter to What
        $QueryFilter.Value = $Filter;  
        $QueryDef.Filter = $QueryFilter; #Add Filter

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;

        foreach ($i in $QueryResults)
        {
            [QueryData]::DesktopInfo += [Sapphire_HorizonView_DesktopInfo]::new($i.DesktopSummaryData.Name, $i.Id);
        }
    }

    static [Sapphire_HorizonView_DesktopInfo[]]QueryDesktops_Get([string]$Filter, [string]$FilterTo)
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [VMware.Hv.QueryFilterContains]$QueryFilter = New-Object VMware.Hv.QueryFilterContains;
        [Object[]]$QueryResults = @();

        [Sapphire_HorizonView_DesktopInfo[]]$tempInfo = @();

        [VMware.Hv.Services]$apiService = Get-ApiService;

        [QueryData]::ClearDesktopQuery();

        $QueryDef.QueryEntityType = 'DesktopSummaryView';
        $QueryDef.Limit = 2000;

        $QueryFilter.MemberName = $FilterTo; #Filter to What
        $QueryFilter.Value = $Filter;  
        $QueryDef.Filter = $QueryFilter; #Add Filter

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;

        foreach ($i in $QueryResults)
        {
            $tempInfo += [Sapphire_HorizonView_DesktopInfo]::new($i.DesktopSummaryData.Name, $i.Id);
        }

        return $tempInfo;
    }

    static [Sapphire_HorizonView_DesktopInfo]GetDesktop([string]$DesktopName)
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [VMware.Hv.QueryFilterEquals]$QueryFilter = New-Object VMware.Hv.QueryFilterEquals;
        [Object]$QueryResults = @();

        [VMware.Hv.Services]$apiService = Get-ApiService;

        $QueryDef.QueryEntityType  ='DesktopSummaryView';

        $QueryFilter.MemberName = 'desktopSummaryData.name';
        $QueryFilter.Value= $DesktopName;
        $QueryDef.Filter = $QueryFilter;

        try 
        {
            $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;
        }
        catch
        {
            Write-Host "Unable to Query Desktop $($DesktopName)";
            return $NULL;
        }

        return [Sapphire_HorizonView_DesktopInfo]::new($QueryResults.DesktopSummaryData.Name, $QueryResults.Id);
    }


    static [Sapphire_HorizonView_EntitledInfo[]]QueryEntitled()  #For Desktop Entitlement 
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [Object[]]$QueryResults = @();

        [VMware.Hv.Services]$apiService = Get-ApiService;

        [QueryData]::ClearEntitledQuery();

        $QueryDef.QueryEntityType = 'EntitledUserOrGroupLocalSummaryView';
        $QueryDef.Limit = 2000;

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;

        foreach ($i in $QueryResults)
        {
            [string[]]$tempDesktops = $NULL; #Use to Store desktop names 

            foreach ($j in $i.LocalData.Desktops) {$tempDesktops += $apiService.Desktop.Desktop_Get($j).Base.Name;}  #Get Desktop Name from ID

            [QueryData]::EntitledInfo += [Sapphire_HorizonView_EntitledInfo]::new($i.LocalData.DesktopUserEntitlements, $i.Base.LoginName.ToString(), $i.Id, $tempDesktops, $i.LocalData.Desktops);
        }

        return [QueryData]::EntitledInfo;
    }

    static [void]QueryEntitled([switch]$NoRet)  #For Desktop Entitlement 
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [Object[]]$QueryResults = @();

        [VMware.Hv.Services]$apiService = Get-ApiService;

        [QueryData]::ClearEntitledQuery();

        $QueryDef.QueryEntityType = 'EntitledUserOrGroupLocalSummaryView';
        $QueryDef.Limit = 2000;

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;

        foreach ($i in $QueryResults)
        {
            [string[]]$tempDesktops = $NULL; #Use to Store desktop names 

            foreach ($j in $i.LocalData.Desktops) {$tempDesktops += $apiService.Desktop.Desktop_Get($j).Base.Name;}  #Get Desktop Name from ID

            [QueryData]::EntitledInfo += [Sapphire_HorizonView_EntitledInfo]::new($i.LocalData.DesktopUserEntitlements, $i.Base.LoginName.ToString(), $i.Id, $tempDesktops, $i.LocalData.Desktops);
        }
    }

    static [Sapphire_HorizonView_EntitledInfo[]]QueryEntitled_Get()  #For Desktop Entitlement 
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [Object[]]$QueryResults = @();

        [Sapphire_HorizonView_EntitledInfo[]]$tempInfo = @();

        [VMware.Hv.Services]$apiService = Get-ApiService;

        [QueryData]::ClearEntitledQuery();

        $QueryDef.QueryEntityType = 'EntitledUserOrGroupLocalSummaryView';
        $QueryDef.Limit = 2000;

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;

        foreach ($i in $QueryResults)
        {
            [string[]]$tempDesktops = $NULL; #Use to Store desktop names 

            foreach ($j in $i.LocalData.Desktops) {$tempDesktops += $apiService.Desktop.Desktop_Get($j).Base.Name;}  #Get Desktop Name from ID

            $tempInfo += [Sapphire_HorizonView_EntitledInfo]::new($i.LocalData.DesktopUserEntitlements, $i.Base.LoginName.ToString(), $i.Id, $tempDesktops, $i.LocalData.Desktops);
        }

        return $tempInfo;
    }

    static [Sapphire_HorizonView_EntitledInfo[]]QueryEntitled([string]$Filter, [string]$FilterTo)
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [VMware.Hv.QueryFilterContains]$QueryFilter = New-Object VMware.Hv.QueryFilterContains;
        [Object[]]$QueryResults = @(0);

        [VMware.Hv.Services]$apiService = Get-ApiService;

        [QueryData]::ClearEntitledQuery();

        $QueryDef.QueryEntityType = 'EntitledUserOrGroupLocalSummaryView';
        $QueryDef.Limit = 2000;

        $QueryFilter.MemberName = $FilterTo; #Filter to What
        $QueryFilter.Value = $Filter;  
        $QueryDef.Filter = $QueryFilter; #Add Filter

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;

        foreach ($i in $QueryResults)
        {
            [string[]]$tempDesktops = $NULL;

            foreach ($j in $i.LocalData.Desktops) {$tempDesktops += $apiService.Desktop.Desktop_Get($j).Base.Name;}  #Get Desktop Name from ID

            [QueryData]::EntitledInfo += [Sapphire_HorizonView_EntitledInfo]::new($i.LocalData.DesktopUserEntitlements, $i.Base.LoginName.ToString(), $i.Id, $tempDesktops, $i.LocalData.Desktops);
        }

        return [QueryData]::EntitledInfo;
    }

    static [void]QueryEntitled([string]$Filter, [string]$FilterTo, [switch]$NoRet)
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [VMware.Hv.QueryFilterContains]$QueryFilter = New-Object VMware.Hv.QueryFilterContains;
        [Object[]]$QueryResults = @();

        [VMware.Hv.Services]$apiService = Get-ApiService;

        [QueryData]::ClearEntitledQuery();

        $QueryDef.QueryEntityType = 'EntitledUserOrGroupLocalSummaryView';
        $QueryDef.Limit = 2000;

        $QueryFilter.MemberName = $FilterTo; #Filter to What
        $QueryFilter.Value = $Filter;  
        $QueryDef.Filter = $QueryFilter; #Add Filter

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;

        foreach ($i in $QueryResults)
        {
            [string[]]$tempDesktops = $NULL;

            foreach ($j in $i.LocalData.Desktops) {$tempDesktops += $apiService.Desktop.Desktop_Get($j).Base.Name;}  #Get Desktop Name from ID

            [QueryData]::EntitledInfo += [Sapphire_HorizonView_EntitledInfo]::new($i.LocalData.DesktopUserEntitlements, $i.Base.LoginName.ToString(), $i.Id, $tempDesktops, $i.LocalData.Desktops);
        }
    }

    static [Sapphire_HorizonView_EntitledInfo[]]QueryEntitled_Get([string]$Filter, [string]$FilterTo)
    {
        [Vmware.Hv.QueryServiceService]$QueryService = New-Object VMware.Hv.QueryServiceService;
        [VMware.Hv.QueryDefinition]$QueryDef = New-Object VMware.Hv.QueryDefinition;
        [VMware.Hv.QueryFilterContains]$QueryFilter = New-Object VMware.Hv.QueryFilterContains;
        [Object[]]$QueryResults = @();

        [Sapphire_HorizonView_EntitledInfo[]]$tempInfo = @();

        [VMware.Hv.Services]$apiService = Get-ApiService;

        [QueryData]::ClearEntitledQuery();

        $QueryDef.QueryEntityType = 'EntitledUserOrGroupLocalSummaryView';
        $QueryDef.Limit = 2000;

        $QueryFilter.MemberName = $FilterTo; #Filter to What
        $QueryFilter.Value = $Filter;  
        $QueryDef.Filter = $QueryFilter; #Add Filter

        $QueryResults = $QueryService.QueryService_Query($apiService, $QueryDef).Results;

        foreach ($i in $QueryResults)
        {
            [string[]]$tempDesktops = $NULL;

            foreach ($j in $i.LocalData.Desktops) {$tempDesktops += $apiService.Desktop.Desktop_Get($j).Base.Name;}  #Get Desktop Name from ID

            $tempInfo += [Sapphire_HorizonView_EntitledInfo]::new($i.LocalData.DesktopUserEntitlements, $i.Base.LoginName.ToString(), $i.Id, $tempDesktops, $i.LocalData.Desktops);
        }

        return $tempInfo;
    }

    
    static [void]ClearQuery() #All
    {
        [QueryData]::ClearUserQuery();
        [QueryData]::ClearMachineQuery();
        [QueryData]::ClearDesktopQuery();
        [QueryData]::ClearEntitledQuery()
    }

    static [void]ClearUserQuery()
    {
        [QueryData]::UserInfo = $NULL;
    }

    static [void]ClearMachineQuery()
    {
        [QueryData]::MachineInfo = $NULL;
    }

    static [void]ClearDesktopQuery()
    {
        [QueryData]::DesktopInfo = $NULL;
    }

    static [void]ClearEntitledQuery()
    {
        [QueryData]::EntitledInfo = $NULL;
    }

    #members 
    static [Sapphire_HorizonView_UserInfo[]]$UserInfo;  #Stored Queries 
    static [Sapphire_HorizonView_MachineInfo[]]$MachineInfo;
    static [Sapphire_HorizonView_DesktopInfo[]]$DesktopInfo;
    static [Sapphire_HorizonView_EntitledInfo[]]$EntitledInfo;

    #static hidden [VMware.Hv.Services]$apiService;
}
#endregion Objects 

#region Functions

###General###
function Install-VMwareModules #Use to install all VMware Modules 
{
    Install-Module -Name Vmware.Vim;
    Install-Module -Name VMware.VimAutomation.Sdk;
    Install-Module -Name VMware.VimAutomation.Core;
    Install-Module -Name VMware.VimAutomation.Common;
    Install-Module -Name VMware.VimAutomation.Cis.Core;
    Install-Module -Name VMware.VimAutomation.Vds;
    Install-Module -Name VMware.VimAutomation.Srm;
    Install-Module -Name VMware.VimAutomation.License;
    #Install-Module -Name VMware.VimAutomation.HorizonView; #Should be installed already
    Install-Module -Name VMware.VimAutomation.Cloud;
    Install-Module -Name VMware.ImageBuilder;
    Install-Module -Name VMware.VimAutomation.Storage;
    Install-Module -Name VMware.DeployAutomation;
    Install-Module -Name VMware.VimAutomation.Vmc; 
    Install-Module -Name VMware.VimAutomation.StorageUtility;
    Install-Module -Name VMware.VimAutomation.StorageUtility;
    Install-Module -Name VMware.VumAutomation;
    Install-Module -Name VMware.VimAutomation.Security;
}

function Get-ApiService #Used in QueryData Class
{
    if ($global:DefaultHVServers.Length -gt 0) #Use First HV Server
    {
        return $global:DefaultHVServers[0].ExtensionData;
    }
    else #No HV Server Connection, setup new one
    {
        Write-Host "***Connect to View Horizon Server***" -ForegroundColor Cyan;
        [string]$Server = Read-Host -Prompt "Server Name";
        [string]$Domain = Read-Host -Prompt "Domain Name";

        return $(Connect-HVServer -Server $Server -Domain $Domain).ExtensionData;
    }
}


###Machine###

function Get-MachineId #By Machine Name 
{
    param([parameter(Mandatory = $true)][string]$MachineName)

    [Sapphire_HorizonView_MachineInfo]$tempInfo = New-Object Sapphire_HorizonView_MachineInfo;

    $tempInfo = [QueryData]::GetMachine($MachineName);

    if ($tempInfo -ne $NULL)
    {
        return $tempInfo.MachineId;
    }
    else
    {
        return $NULL;
    }
}

function ConvertFrom-MachineId #Machine Id To Machine Name 
{
    param([parameter(Mandatory = $true)][Vmware.Hv.EntityId]$MachineId);

    [VMware.Hv.Services]$apiService = Get-ApiService;

    return $apiService.Machine.Machine_Get($MachineId).Base.Name;
}

function Convert-MachineIdToUserId  #Get User ID From Machine 
{
    param([parameter(Mandatory = $true)][VMware.Hv.EntityId]$MachineId);

    [Vmware.Hv.Services]$apiService = Get-ApiService;

    return $apiService.Machine.Machine_GetSummaryView($MachineId).Base.User;
}

function Convert-MachineIdToDesktopId #Pool Id 
{
    param([parameter(Mandatory = $true)][VMware.Hv.EntityId]$MachineId);

    [VMware.Hv.Services]$apiService = Get-ApiService;

    return $apiService.Machine.Machine_Get($MachineId).Base.Desktop;
}

function Push-UserToMachine #WIP
{
    [CmdletBinding()]
    param([parameter(Mandatory = $true, Position = 0<#, ParameterSetName = "Username"#>)][string]$Username,  #Could probably be set to accept both name and ID using Dynamic params
        [parameter(Mandatory = $true, Position = 0<#, ParameterSetName = "UserId"#>)][VMware.Hv.EntityId]$UserId,
        [parameter(Mandatory = $true, Position = 1<#, ParameterSetName = "MachineName"#>)][string]$MachineName,
        [parameter(Mandatory = $true, Position = 1<#, ParameterSetName = "MachineId"#>)][VMware.Hv.EntityId]$MachineId,
        [parameter(Mandatory = $false)][string]$DomainName,
        [parameter(Mandatory = $false)][switch]$AddEntitlement);

    [VMware.Hv.Services]$apiService = Get-ApiService;
    [VMware.Hv.MachineService]$MachineService = New-Object VMware.Hv.MachineService;
    [VMware.Hv.MachineService+MachineInfoHelper]$MachineInfo = New-Object VMware.Hv.MachineService+MachineInfoHelper;  

    if ($UserId.Length -lt 1) #Set UserId
    {   
        $UserId = Get-UserId -Username $Username;
    }
    elseif ($Username.Length -lt 1) #Set Username
    {
        $Username = ConvertFrom-UserId -UserId -$Username;
    }

    if ($MachineName.Length -gt 0) #Set MachineId
    {
        MachineId = $(Get-MachineId -MachineName $MachineName);
    } 
    elseif ($PSBoundParameters["Verbose"]) {$MachineName = ConvertFrom-MachineId -MachineId $MachineId;}  #If Verbose and Machine name not already set, name is used in verbose out put

    $MachineInfo = $MachineService.read($apiService, $MachineId);  #read desktop info from deskop service 

    #if ($PSBoundParameter["Verbose"]) {Write-Host "Adding $Username to $MachineName";}
    Write-Verbose "Adding $Username to $MachineName";

    <#if ($AddEntitlement) #Make Seperate
    {   
        if ($DomainName.Length -lt 1) #Check for Domain
        { 
            $DomainName = Read-Host -Prompt "Enter Domain Name";  
        }

        if ($Username.Length -lt 1) #Confirm Username is set
        {
            $Username = ConvertFrom-UserId -UserId $UserId;
        }

        $Username = $DomainName + '\' + $Username;
        New-HVEntitlement -ResourceName $(Convert-MachineIdToDesktopId -MachineId $MachineId) -ResourceType Desktop -User $Username;
    } #>#Needs Domain

    $MachineInfo.getBaseHelper().setUser($UserId); #Needs Id 
    $MachineService.update($MachineInfo); #Push Update 
}

function Pop-UserFromMachine #Remove User from machine
{
    [CmdletBinding()]
    param([parameter(Mandatory = $true, Position = 0, ParameterSetName = "MachineId")][Vmware.Hv.EntityId]$MachineId,
        [parameter(Mandatory = $true, Position = 0, ParameterSetName = "MachineName")][string]$MachineName);

    [VMware.Hv.Services]$apiService = Get-ApiService;
    [Vmware.Hv.MachineService]$MachineService = New-Object Vmware.Hv.MachineService;
    [Vmware.Hv.MachineService+MachineInfoHelper]$MachineInfo = New-Object VMware.Hv.MachineService+MachineInfoHelper;

    if ($MachineName.Length -gt 0)
    {
        $MachineId = $(Get-MachineId -MachineName $MachineName);
    }
    elseif ($PSBoundParameters["Verbose"]){$MachineName = ConvertFrom-MachineId -MachineId $MachineId;}

    $MachineInfo = $MachineService.read($apiService, $MachineId);

    if ($PSBoundParameters["Verbose"]){Write-Host "Removing $($MachineInfo.getBaseHelper.getUser()) from $MachineName"}

    $MachineInfo.getBaseHelper().setUser($NULL);
    $MachineService.update($apiService, $MachineInfo); #Push Update 
}


###Desktop Pool stuff###
function Get-DesktopId #By Pool Name 
{
    param([parameter(Mandatory = $true)][string]$DesktopName)

    [Sapphire_HorizonView_DesktopInfo]$tempInfo = New-Object Sapphire_HorizonView_DesktopInfo;

    $tempInfo = [QueryData]::GetDesktop($DesktopName);

    if ($tempInfo -ne $NULL)
    {
        return $tempInfo.DesktopId;
    }
    else
    {
        return $NULL;
    }
}

function ConvertFrom-DesktopId #Takes Pool/Desktop Id and converts it to Pool/Desktop Name 
{
    param([parameter(Mandatory = $true)][Vmware.Hv.EntityId]$DesktopId);

    [VMware.Hv.Services]$apiService = Get-ApiService;

    return $apiService.Desktop.Desktop_Get($DesktopId).Base.Name.ToString();
}

function Get-AutoPoolSize
{
    param([parameter(Mandatory = $true, Position = 0, ParameterSetName = "DesktopName")][string]$DesktopName,
        [parameter(Mandatory = $true, Position = 0, ParameterSetName = "DesktopId")][VMware.Hv.EntityId]$DesktopId);

    [VMware.Hv.DesktopService]$PoolService = New-Object Vmware.Hv.DesktopService;
    [VMware.Hv.DesktopService+DesktopInfoHelper]$PoolInfo = New-Object VMware.Hv.DesktopService+DesktopInfoHelper;
    [Vmware.Hv.Services]$apiService = Get-ApiService;

    if ($DesktopName.Length -gt 0)
    {
        $DesktopId = Get-DesktopId -DesktopName $DesktopName;
    }

    $PoolInfo = $PoolService.read($apiService, $DesktopId);
    return $PoolInfo.getAutomatedDesktopDataHelper().getVmNamingSettingsHelper().getPatternNamingSettingsHelper().getMaxNumberOfMachines(); #Int32
}

function Add-AutoPoolMachine #Add 1 to max machines
{
    [CmdletBinding()]
    param([parameter(Mandatory = $true, Position = 0, ParameterSetName = "PoolName")][string]$PoolName,
        [parameter(Mandatory = $true, Position = 0, ParameterSetName = "PoolId")][Vmware.Hv.EntityId]$PoolId);

    [int]$NewSize;

    if ($PoolName.Length -gt 0)
    {
        $PoolId = Get-DesktopId -DesktopName $PoolName;  
    }
    
    $NewSize = $(Get-AutoPoolSize -PoolId $PoolId) + 1;
    Resize-AutoPool -PoolId $PoolId -NewSize $NewSize; 

    if ($PSBoundParameter["Verbose"]){Write-Host "Increasing Pool Size from $($NewSize - 1) to $NewSize";}
}

function Remove-AutoPoolMachine #Subtract 1 from max machines
{
    [CmdletBinding()]
    param([parameter(Mandatory = $true, Position = 0, ParameterSetName = "PooolName")][string]$PoolName,
        [parameter(Mandatory = $true, Position = 0, ParameterSetName = "PoolId")][VMware.Hv.EntityId]$PoolId);

    [int]$NewSize;

    if ($PoolName.Length -gt 0)
    {
        $PoolId = Get-DesktopId -DesktopName $PoolName;
    }

    $NewSize = $(Get-AutoPoolSize) - 1;
    Resize-AutoPool -PoolId $PoolId -NewSize $NewSize;

    if ($PSBoundParameter["Verbose"]){Write-Host "Decreasing Pool Size from $($NewSize + 1) to $NewSize";}
}

function Resize-AutoPool #Update Max size of VMware Auto Pool
{
    param([parameter(Mandatory = $true, Position = 0, ParameterSetName = "PoolName")][string]$PoolName,
        [parameter(Mandatory = $true, Position = 0, ParameterSetName = "PooId " )][VMware.Hv.EntityId]$PoolId,
        [parameter(Mandatory = $true)][int]$NewSize);

    [VMware.Hv.DesktopService]$PoolService = New-Object VMware.Hv.DesktopService;
    [VMware.Hv.Services]$apiService = Get-ApiService;

    
    if ($PoolName.Length -gt 0)
    {
        $PoolId = Get-DesktopId -DesktopName $PoolName;
    }

    $PoolInfo = $PoolService.read($apiService, $PoolId);

    $PoolInfo.getAutomatedDesktopDataHelper().getVmNamingSettingsHelper().getPatternNamingSettingsHelper().setMaxNumberOfMachines($NewSize);
    $PoolService.update($apiService, $PoolInfo);
}

###User Stuff###
function Get-UserEntitlements #From Username/UserId
{   #Will return Desktop Pool names by default
    param([parameter(Mandatory = $true, Position = 0, ParameterSetName = "Username")][string]$Username,
        [parameter(Mandatory = $true, Position = 0, ParameterSetName = "UserId")][VMware.Hv.EntityId]$UserId,
        [parameter(Mandatory = $false)][switch]$AsEntitlementId); #Return Id instead

    [VMware.Hv.Services]$apiService = Get-ApiService;
    [Vmware.Hv.EntityId[]]$userEntitlementIds = New-Object VMware.Hv.EntityId;
    [string[]]$PoolNames = $NULL;

    if ($Username.Length -gt 0)
    {
        $UserId = Get-UserId -Username $Username;
    }

    #$userEntitlementIds = $apiService.EntitledUserOrGroup.EntitledUserOrGroup_Get($UserId).LocalData.DesktopUserEntitlements;
    $userEntitlementIds = $apiService.EntitledUserOrGroup.EntitledUserOrGroup_Get($UserId).LocalData.Desktops; #<-Better Method?

    if ($AsEntitlementId)
    {
        return $userEntitlementIds;
    }
    else 
    {
        foreach ($i in $userEntitlementIds)
        {
            $PoolNames += ConvertFrom-DesktopId -DesktopId $i;
        }

        return $PoolNames;
    }
}

function Get-UserId #Username to UserId 
{
    param([parameter(Mandatory = $true)][string]$Username)

    [Sapphire_HorizonView_UserInfo]$tempInfo = New-Object Sapphire_HorizonView_UserInfo;

    $tempInfo = [QueryData]::GetUsername($Username);

    if ($tempInfo -ne $NULL)
    {
        return $tempInfo.UserId;
    }
    else
    {
        return $NULL;
    }
}

function Search-UserInfo #Search last query with REGEX
{
    param([parameter(Mandatory = $false, Position = 0, ParameterSetName = 'Username')][string]$Username,  #leave as string, do not change to REGEX type
        [parameter(Mandatory = $false, Position = 1, ParameterSetName = 'UserId')][VMware.Hv.EntityId]$UserId);

    [Sapphire_HorizonView_UserInfo[]]$infoMatch = New-Object Sapphire_HorizonView_UserInfo;

    if ([QueryData]::UserInfo.Count -eq 0) #confirm array is not empty
    {
        [QueryData]::QueryUsers($NoRet); #Store info in Query if not already set 
    }

    for ([int]$i = 0; $i -lt [QueryData]::UserInfo.Count; $i++) 
    {
        if ([QueryData]::UserInfo[$i].Username -notmatch $Username -and $Username.Length -gt 0)
        {
            continue;
        }
        elseif ([QueryData]::UserInfo[$i].UserId -notmatch $UserId -and $UserId.Length -gt 0)
        {
            continue;
        }
        else
        {
            $infoMatch += [QueryData]::UserInfo[$i];
        }
    }

    return $infoMatch;
}

function Convert-UserEntitlementIdToDesktopId 
{
    param([parameter(Mandatory = $true)][VMware.Hv.EntityId]$UserEntitlementId);

    [Vmware.Hv.Services]$apiService = Get-ApiService;

    return $apiService.UserEntitlement.UserEntitlement_Get($UserEntitlementId).Base.get_Resource();
}

function ConvertFrom-UserId #Returns LoginName 
{
    param([parameter(Mandatory = $true)][VMware.Hv.EntityId]$UserId);

    [VMware.Hv.Services]$apiService = Get-ApiService;

    return $apiService.ADUserOrGroup.ADUserOrGroup_Get($UserId).Base.LoginName;
}

#endregion Functions

#region Export
Export-ModuleMember -Function Add-AutoPoolMachine;
Export-ModuleMember -Function Convert-MachineIdToDesktopId;
Export-ModuleMember -Function Convert-MachineIdToUserId;
Export-ModuleMember -Function Convert-UserEntitlementIdToDesktopId;
Export-ModuleMember -Function ConvertFrom-DesktopId;
Export-ModuleMember -Function ConvertFrom-MachineId;
Export-ModuleMember -Function ConvertFrom-UserId;
Export-ModuleMember -Function Get-AutoPoolSize;
Export-ModuleMember -Function Get-MachineUser;
Export-ModuleMember -Function Get-MachineId;
Export-ModuleMember -Function Get-DesktopId;
Export-ModuleMember -Function Get-UserId;
Export-ModuleMember -Function Get-UserEntitlements;
Export-ModuleMember -Function Install-VMwareModules;
Export-ModuleMember -Function Pop-UserFromMachine;
#Export-ModuleMember -Function Push-UserToMachine;
Export-ModuleMember -Function Resize-AutoPool;
Export-ModuleMember -Function Remove-AutoPoolMachine;
Export-ModuleMember -Function Search-UserInfo;
#endregion
