#***************************************************************************************
################## TAKING THE BACKUP OF SPLUNK DATA #########################
#***************************************************************************************

$servers = Get-Content "C:\Temp\splunk-servers.txt"

foreach($server in $servers){

#$creds= Get-Credential

$session = New-SSHSession -ComputerName fishcljmp01 -Credential $creds

$op = Invoke-SSHCommand -SSHSession $session -Command "scp -r ext_vkrishna@10.125.97.210:/home/ext_vkrishna/f1 c:\temp"

$op.Output | Out-File c:\temp\scp.txt

}

# "scp -r ext_vkrishna@10.125.97.210:/home/ext_vkrishna/f1 c:\temp"