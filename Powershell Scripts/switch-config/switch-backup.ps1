#********************************************************************************************************************************************************************
#****************************************************************** SWITCH BACKUP ***********************************************************************************
#********************************************************************************************************************************************************************

# Getting the list of switches

$switches = Get-Content -Path "C:\Users\ext_vkrishna\Desktop\Powershell Scripts\switch-config\test-switches.txt"

$creds = Get-Credential

foreach($switch in $switches){

$ssh = New-SSHSession -ComputerName $switch -Credential $creds -ConnectionTimeout 300 

$op = Invoke-SSHCommand -SSHSession $ssh -Command "show running-config" -TimeOut 300

$op.output | Out-File "C:\Users\ext_vkrishna\Desktop\Powershell Scripts\switch-config\configuration\$switch.txt"

}