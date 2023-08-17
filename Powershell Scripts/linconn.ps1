<#
$var = Read-Host -Prompt "Enter password for $server" -AsSecureString 
$var
$pass1 = (New-Object PSCredential 0, $var).GetNetworkCredential().Password
$pass1
#>
param(
$pass1)
Start-Process pscp.exe -ArgumentList ("-scp -r -pw $pass1 ext_vkrishna@10.125.97.210:/home/ext_vkrishna/f5 c:\temp")