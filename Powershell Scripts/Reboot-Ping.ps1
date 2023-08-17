######################################## RESTART THE COMPUTER AND PING THE AVAILABILITY STATUS #############################################################

# Getting the list of Servers

$servers = Get-Content -Path "C:\Temp\reboot-servers.txt"

$date = Get-Date -Format dd-MM-yyyyT-hhmmss

foreach($server in $servers){

$osname = Get-WmiObject win32_operatingsystem -ComputerName $server -ea silentlycontinue

if($osname){

$lastbootuptime =$osname.ConvertTodateTime($osname.LastBootUpTime) 

$output =New-Object psobject 

$output |Add-Member noteproperty LastBootUptime $LastBootuptime 

$output |Add-Member noteproperty ComputerName $server

}

else{

$output =New-Object psobject 
  
$output |Add-Member noteproperty LastBootUptime "Not Available" 
  
$output |Add-Member noteproperty ComputerName $server

}

$output | select Computername, LastBootUptime | Export-Excel -Path C:\Temp\LastBootUptime-$date.xlsx -WorksheetName "Before Restart" -TitleBold -BoldTopRow -Append -AutoSize

# Initiating the restart 

Restart-Computer -ComputerName $server -Force -Wait -For PowerShell -Timeout 300 -Delay 2

sleep -Seconds 10

# Check the lastbootuptime after the restart

$osname = Get-WmiObject win32_operatingsystem -ComputerName $server -ea silentlycontinue

if($osname){

$lastbootuptime =$osname.ConvertTodateTime($osname.LastBootUpTime) 

$output =New-Object psobject 

$output |Add-Member noteproperty LastBootUptime $LastBootuptime 

$output |Add-Member noteproperty ComputerName $server

}

else{

$output =New-Object psobject 
  
$output |Add-Member noteproperty LastBootUptime "Not Available" 
  
$output |Add-Member noteproperty ComputerName $server

}

$output | select Computername, LastBootUptime | Export-Excel -Path C:\Temp\LastBootUptime-$date.xlsx -WorksheetName "After Restart" -TitleBold -BoldTopRow -Append -AutoSize

}