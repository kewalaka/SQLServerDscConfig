Configuration SQLInstallInstance
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        $SqlInstallParameters,

        [ValidateSet('2014', '2016', '2017', '2019')]
        $SQLVersion = '2016'
    )

    Import-DSCResource -ModuleName PSDscResources -ModuleVersion 2.10.0.0
    Import-DSCResource -ModuleName SQLServerDsc -ModuleVersion 12.4.0.0

    # pre-requisites
    # TODO - what if there is no internet to get .Net 3
    # TODO - does not consider pre-staging files needed for R/Python 
    if ($SQLVersion -eq '2014')
    {
        Script enableDotNet
        {
            GetScript = {(Get-WindowsOptionalFeature -FeatureName 'NetFx3' -Online).State}
            TestScript = {(Get-WindowsOptionalFeature -FeatureName 'NetFx3' -Online).State -eq 'Enabled'}
            SetScript = {Enable-WindowsOptionalFeature -FeatureName 'NetFx3' -NoRestart -Online -All}
        }
        
        WindowsFeature 'NetFramework45'
        {
            Name   = 'NET-Framework-45-Core'
            Ensure = 'Present'
            DependsOn = '[Script]enableDotNet'
        }        
    }
    else
    {
        WindowsFeature 'NetFramework45'
        {
            Name   = 'NET-Framework-45-Core'
            Ensure = 'Present'
        }
    }

    # if an instance name has not been specified, create a default instance
    if (-not $SqlInstallParameters.Keys -contains 'InstanceName')
    {
        $SqlInstallParameters.InstanceName = 'MSSQLSERVER'
    }
    $SqlInstallParameters.DependsOn = '[WindowsFeature]NetFramework45'

    $executionName = $SqlInstallParameters.InstanceName
    (Get-DscSplattedResource -ResourceName SqlSetup -ExecutionName $executionName -Properties $SqlInstallParameters -NoInvoke).Invoke($SqlInstallParameters)

    # TODO: service pack / CU (using chocolatey?)

}