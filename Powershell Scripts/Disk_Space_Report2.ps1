#********************************************************************************************************************************************************************
#*************************************************************** DISK SPACE UTILIZATION REPORT **********************************************************************#
#********************************************************************************************************************************************************************

# Place the list of servers here
$servers = Get-Content -Path "C:\Temp\Disk Space Reports\Diskcheck-servers.txt" 

$date = Get-Date -Format dd-MM-yyyyT-hhmmss

#$servers = "MADWINTEL01","FISMGMT003"

$outarr = @()

$totarr = @()

foreach($server in $servers){

$result = Get-CimInstance -ComputerName $server -ClassName Win32_volume | select @{Name="ServerName";Expression={$server}},@{Name="Drive";Expression={$_.Name}}, Label,FileSystem, @{Name="Capacity(GB)";Expression={[Math]::Ceiling($_.Capacity/1gb)}}, 

@{Name="Freespace(GB)";Expression={[Math]::Ceiling($_.freespace/1gb)}}, @{Name="UsedSpace(GB)";Expression={[Math]::Ceiling(($_.Capacity - $_.freespace)/1GB)}},

@{Name="Used(%)";Expression={[Math]::Ceiling(($_.Capacity - $_.freespace)/$_.Capacity * 100)}}


#Get the total disk used space

$total = 0

$atotal = 0

foreach($item in $result){

    $asize = $item.'Capacity(GB)'

    $atotal+=$asize

    $uspace = $item."UsedSpace(GB)"

    $total+=$uspace

}

$obj = "" | Select @{Name="ServerName";Expression={$server}}, @{Name="Total Disk Size(GB)";e={$atotal}}, @{Name="Total Used Space(GB)";e={$total}},@{Name="Used(%)";e={[math]::Ceiling(($total/$atotal)*100)}},@{Name="Free Space(%)";e={[math]::Ceiling(($atotal-$total)/$atotal*100)}}

$totarr+=$obj

$outarr+=$result

}

$totarr | Export-Excel -Path "C:\Temp\Disk Space Reports\Disk Space Report-$date.xlsx" -WorksheetName "Total Size" -BoldTopRow -AutoSize -AutoFilter

$outarr | Export-Excel -Path "C:\Temp\Disk Space Reports\Disk Space Report-$date.xlsx" -WorksheetName "Drive Size" -BoldTopRow -AutoSize -AutoFilter


#*********************************************************************** END OF THE SCRIPT **************************************************************************