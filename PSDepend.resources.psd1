@{
    PSDependOptions = @{
        AddToPath = $True
        Target = 'DSC_Resources'
        Parameters = @{
            #Force = $True
            #Import = $True
        }
    }

    PSDesiredStateConfiguration = 'latest'
    SQLServerDsc                = 'latest'
    SecurityPolicyDsc           = 'latest'  
}