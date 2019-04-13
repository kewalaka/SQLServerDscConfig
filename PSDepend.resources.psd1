@{
    PSDependOptions = @{
        AddToPath = $True
        Target = 'DSC_Resources'
        Parameters = @{
            #Force = $True
            #Import = $True
        }
    }

    PSDscResources            = '2.10.0.0'
    SQLServerDsc              = '12.4.0.0'
    SecurityPolicyDsc         = '2.8.0.0'  
}