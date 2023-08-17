$creds= Get-Credential

$session = New-SSHSession -ComputerName fishcljmp01 -Credential $creds

$op = Invoke-SSHCommand -SSHSession $session -Command "ls"#"pscp -r ext_vkrishna@10.125.97.210:/home/ext_vkrishna/f1 c:\temp"