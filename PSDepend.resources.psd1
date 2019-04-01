@{
    PSDependOptions = @{
        AddToPath = $True
        Target = 'DSC_Resources'
        Parameters = @{
            #Force = $True
            #Import = $True
        }
    }

    PSDscResources            = 'latest'
    SQLServerDsc              = 'latest'
    SecurityPolicyDsc         = 'latest'  
}