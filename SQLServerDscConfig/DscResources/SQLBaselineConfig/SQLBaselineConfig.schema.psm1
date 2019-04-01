Configuration SQLBaselineConfig
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        $SqlAdminCredential,

        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        $SqlServiceCredential,
        
        $SysAdmins = @(),
        $TCPPort = 1433,

        $NameOfInstance = 'MSSQLSERVER', # MSSQLSERVER = default instance
        $MediaSource = 'C:\Install\SQL\ExtractedISO',       
        $MemorySettings,
        $MixedModeAuth = $false
    )

    Import-DSCResource -ModuleName PSDscResources, SQLServerDsc, SecurityPolicyDsc

    $ServerName = 'localhost'

    # if memory settings are not specified then use dynamic allocation
    If (-not $MemorySettings)
    {
        $MemorySettings.DynamicAlloc = $true
    }
    $MemorySettings.InstanceName = $NameOfInstance

    (Get-DscSplattedResource -ResourceName SqlServerMemory -ExecutionName 'Set_SQLServerMemory' -Properties $MemorySettings -NoInvoke).Invoke($MemorySettings)


    #TODO - mixed mode auth
    <#

    #not great - requires knowledge of SQL server - does not flag SQL needs to restart

    Registry SetMixedModeAuth {
        Ensure      = 'Present'        
        Key         = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL13.MSSQLSERVER\$NameOfInstance"
        ValueName   = 'LoginMode'
        ValueData   = $RegKeyValue
        ValueType   = 'Dword'
        Force       = $true
    }

    #better but depends on https://github.com/PowerShell/SqlServerDsc/issues/1139

    SQLSecurity SetMixedModeAuth {

    }
    #>

    # note that a reboot is required for this to take effect, this is not flagged
    SqlWindowsFirewall Create_FirewallRules {
        Features         = 'SQLENGINE'
        InstanceName     = $NameOfInstance
        SourcePath       = $SourcePath
    }    
    #endregion

    # auto is calculated as per this formula
    # https://github.com/PowerShell/SqlServerDsc#formula-for-dynamically-allocating-max-degree-of-parallelism
    SqlServerMaxDop Set_SQLServerMaxDop_ToAuto
    {
        DynamicAlloc            = $true
        InstanceName            = $NameOfInstance
        DependsOn               = '[Script]checkSQLInstalled'
    }    

    # Ensure TCP is enabled, configure SQL with a static port - TCP1433
    SqlServerNetwork 'ChangeTcpIpOnDefaultInstance'
    {
        InstanceName         = $NameOfInstance
        ProtocolName         = 'Tcp'
        IsEnabled            = $true
        TCPDynamicPort       = $false
        TCPPort              = $TCPPort
        RestartService       = $false
    }

    # enable backup compression by default
    SqlServerConfiguration 'BackupCompressionDefault' 
    {
        ServerName     = $ServerName    
        InstanceName   = $NameOfInstance
        OptionName     = 'backup compression default'
        OptionValue    = 1
        RestartService = $false        
    }

    if ($SqlServiceCredential -ne '') {
        # this allows SQL to perform instant file initialization
        # https://docs.microsoft.com/en-us/sql/relational-databases/databases/database-instant-file-initialization
        UserRightsAssignment PerformVolumeMaintenanceTasks 
        {
            Policy   = "Perform_volume_maintenance_tasks"
            Identity = $SqlServiceCredential.UserName
        }
    }

    # enable remote dedicated admin connection
    # https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/remote-admin-connections-server-configuration-option?view=sql-server-2017
    SqlServerConfiguration 'EnableDedicatedAdminConnection'
    {
        ServerName     = $ServerName    
        InstanceName   = $NameOfInstance
        OptionName     = 'remote admin connections'
        OptionValue    = 1
        RestartService = $false
    }

    # model is the default used for other databases
    SqlDatabaseRecoveryModel 'ModelDBRecoveryModel'
    {
        Name                 = 'model'
        RecoveryModel        = 'Full'
        ServerName           = $ServerName
        InstanceName         = $NameOfInstance
        PsDscRunAsCredential = $SqlAdminCredential
    }
}


