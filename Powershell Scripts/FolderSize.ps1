#TASK: Getting the size of each folder of a Drive

$colItems = Get-ChildItem D: | Where-Object {$_.PSIsContainer -eq $true} | Sort-Object

foreach ($i in $colItems)
{

$subFolderItems = Get-ChildItem $i.FullName -recurse -force | Where-Object {$_.PSIsContainer -eq $false} | Measure-Object -property Length -sum | Select-Object Sum

$Pstable= [PSCustomObject]@{

ServerName = $env:COMPUTERNAME

FullPath = $i.FullName

Drive = ($i.FullName -split ':')[0]

"Size(GB)" = “{0:N2}” -f ($subFolderItems.sum / 1GB) 

CreationDate = $i.CreationTime

} 

$Pstable | Export-Csv -Path "C:\Temp\folder5.csv" -Append -NoTypeInformation 

}