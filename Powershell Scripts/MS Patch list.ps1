Clear-Host

$FileName = "C:\Temp\Installed_Patches.csv"

if (Test-Path $FileName) {

  Remove-Item $FileName

  Write-Host "Deleted the Existing OutPut file" -BackgroundColor Red -ForegroundColor Green

}

$serversToCheck = Get-Content "C:\temp\Servers.txt"

$outfile = "C:\Temp\Installed_Patches.csv"

ForEach ( $server in $serversToCheck )

{

    $out = Invoke-Command -ComputerName $server -scriptblock { 

    Get-WmiObject Win32_QuickFixEngineering |

    Select-Object -Property PSComputerName, Description, InstalledOn, HotFixID, InstalledBy, @{n='Server_Boot_Time';e={Get-CimInstance -ClassName win32_operatingsystem | select -ExpandProperty lastbootuptime}}} 
    
    $out |Select-Object -Property PSComputerName, Description, InstalledOn, HotFixID, InstalledBy,Server_Boot_Time | Export-Csv -Path $outfile -Append -NoTypeInformation

} 

Send-MailMessage -SmtpServer "" -From "" -To "" -Cc "" -Subject "Installed_Patches" -Attachments "C:\Temp\Installed_Patches.csv"
