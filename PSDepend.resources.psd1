@{
    PSDependOptions = @{
        AddToPath = $True
        Target = 'DSC_Resources'
        Parameters = @{
            #Force = $True
            #Import = $True
        }
    }

    xPSDesiredStateConfiguration = 'latest'
    SQLServerDsc                 = 'latest'
    SecurityPolicyDsc            = 'latest'  
}