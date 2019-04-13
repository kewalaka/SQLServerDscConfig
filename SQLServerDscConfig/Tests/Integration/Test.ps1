Import-Module -force Datum -Global -errorAction Stop

$DatumConfig = Join-Path  $PSScriptRoot "Datum.yml"
Write-Warning "Loading $DatumConfig"

$Global:Datum = New-DatumStructure -definitionFile $DatumConfig

$AllNodes = @($Datum.TestConfigs.psobject.Properties | ForEach-Object { 
    $Node = $Datum.TestConfigs.($_.Name)
    if(!$Node.contains('Name') ) {
        $null = $Node.Add('Name',$_.Name)
    }
    (@{} + $Node) #Remove order & Case Sensitivity
})

$Global:ConfigurationData = @{
    AllNodes = $AllNodes
    Datum = $Global:Datum
}

#ipmo -force $PSScriptRoot\..\SQLServerDscConfig.psd1
$Properties = $(Lookup 'SQLInstallInstance')

Configuration Default {
    #Import-DSCresource -ModuleName SQLServerDsc -ModuleVersion 12.4.0.0

    Import-DSCresource -ModuleName SQLServerDscConfig

    Node $ConfigurationData.AllNodes.NodeName {

      #Auto lookup Parameters for $node with Configuration
      $Properties = $(Lookup 'SQLInstallInstance')
      (Get-DscSplattedResource -ResourceName 'SQLInstallInstance' -ExecutionName 'SQLInstallInstance_FromNodeBlock' -Properties $Properties -NoInvoke).Invoke($Properties)

    }
}

Default -ConfigurationData $ConfigurationData -OutputPath $(Join-Path $env:BHProjectPath -ChildPath 'DscBuildOutput\')