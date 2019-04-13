Configuration SQLDatabaseMail
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        $DatabaseMailParameters,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        $SqlAdminCredential
    )

    Import-DSCResource -ModuleName SQLServerDsc -ModuleVersion 12.4.0.0

    $ServerName = 'localhost'

    # turn on database mail
    SqlServerConfiguration 'EnableDatabaseMailXPs'
    {
        ServerName     = $ServerName
        InstanceName   = $DatabaseMailParameters.InstanceName
        OptionName     = 'Database Mail XPs'
        OptionValue    = 1
        RestartService = $false
    } 
    $DatabaseMailParameters.PsDscRunAsCredential = $SqlAdminCredential

    (Get-DscSplattedResource -ResourceName SqlServerDatabaseMail -ExecutionName 'Set_SqlServerDatabaseMail' -Properties $DatabaseMailParameters -NoInvoke).Invoke($DatabaseMailParameters)

}
