
$ssh = New-SSHSession -ComputerName 10.3.0.10 -Credential $creds -ConnectionTimeout 300 -Force
$op4 = Invoke-SSHCommand -SSHSession $ssh -Command "show running-config" -TimeOut 300
