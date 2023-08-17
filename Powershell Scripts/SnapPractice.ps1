 $rg = Get-AzResourceGroup |select  ResourceGroupName
 foreach($r in $rg){
    $snap = Get-AzSnapshot -ResourceGroupName $r.ResourceGroupName | Where-Object TimeCreated -lt (Get-Date).AddDays(-90).ToUniversalTime()
   
    #$snap 
    }

# AzureBackup_bcaf2a2f-23a2-4482-abe6-b3d234b88eee_2022-06-29T09-02-46.1652996
$op = Get-AzSnapshot | Where-Object TimeCreated -lt (Get-Date).AddDays(-30).ToUniversalTime() | select name