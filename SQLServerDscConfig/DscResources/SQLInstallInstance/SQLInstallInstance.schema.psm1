Configuration SQLInstallInstance
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        $SqlInstallParamaters,

        [ValidateSetAttribute('2014', '2016', '2017', '2019')]
        $SQLVersion = '2016'
    )

    Import-DSCResource -ModuleName PSDscResources, SQLServerDsc

    # pre-requisites
    # TODO - what if there is no internet to get .Net 3
    # TODO - does not consider pre-staging files needed for R/Python 
    if ($SQLVersion = '2014')
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
    if (-not $SqlInstallParamaters.ContainsKey('InstanceName'))
    {
        $SqlInstallParamaters.InstanceName = 'MSSQLSERVER'
    }
    $SqlInstallParamaters.DependsOn = '[WindowsFeature]NetFramework45'

    $executionName = $SqlInstallParamaters.InstanceName
    (Get-DscSplattedResource -ResourceName SqlSetup -ExecutionName $executionName -Properties $SqlInstallParamaters -NoInvoke).Invoke($SqlInstallParamaters)

    # TODO: service pack / CU (using chocolatey?)

}