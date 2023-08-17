Set-AzContext -Subscription "developmentSub"
$snaps = Get-AzSnapshot # -ResourceGroupName $RG.ResourceGroupName | Where-Object TimeCreated -lt (Get-Date).AddDays(-90).ToUniversalTime()
$snaps | select Name

$sub = "developmentSub"
$dt = Get-Date -Format "dd-MM-yyyy"
Get-AzSnapshot | select Name,ResourceGroupName,TimeCreated | Export-Csv -Path C:\temp\$sub-snapshots-$dt -NoTypeInformation
