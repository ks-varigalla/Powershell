# Connect to Azure with system-assigned managed identity

#Connect-AzAccount -Identity

$SubscriptionName = "developmentSub"

Set-AzContext -SubscriptionName "$SubscriptionName" 

$RGs = Get-AzResourceGroup

foreach ($RG in $RGs) {

    $Snapshots = Get-AzSnapshot -ResourceGroupName $RG.ResourceGroupName | Where-Object TimeCreated -lt (Get-Date).AddDays(-90).ToUniversalTime()

    foreach ($Snapshot in $Snapshots) {

        $Name = $Snapshot.Name

        $ResourceGroupName = $Snapshot.ResourceGroupName
        
        #Remove-AzSnapshot -ResourceGroupName $ResourceGroupName -SnapshotName $Name -Force 

        Write-Output " Deleted $Name - $ResourceGroupName"



    }

}