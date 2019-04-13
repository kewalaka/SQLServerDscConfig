param (
    [string[]]
    $ModuleToLeaveLoaded = (property ModuleToLeaveLoaded @('InvokeBuild', 'PSReadline', 'PackageManagement', 'xPSDesiredStateConfiguration', 'PowerShellGet') )
)
task SetPsModulePath {
    if (-not ([System.IO.Path]::IsPathRooted($BuildOutput)))
    {        
        $BuildOutput = Join-Path -Path $ProjectPath -ChildPath $BuildOutput        
    }
    
    $resourcePath = Join-Path -Path $ProjectPath -ChildPath 'DSC_Resources'
    $CompositeResourcePath = $ProjectPath
    $buildModulesPath = Join-Path -Path $BuildOutput -ChildPath Modules

    $pathToSet = $buildModulesPath, $resourcePath, $CompositeResourcePath
    if ($env:BHBuildSystem -eq 'AppVeyor') {
        $pathToSet += ';C:\Program Files\AppVeyor\BuildAgent\Modules'
    }

    Set-PSModulePath -ModuleToLeaveLoaded $moduleToLeaveLoaded -PathsToSet $pathToSet

    "`n"
    "PSModulePath:"
    $env:PSModulePath -split ';'
    "`n"
    
}