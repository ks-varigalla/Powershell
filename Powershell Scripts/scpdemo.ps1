$creds= Get-Credential
$session = New-SSHSession -ComputerName fishcljmp01 -Credential $creds

$op = Invoke-SSHCommand -SSHSession $session -Command "ls"#"pscp -r ext_vkrishna@10.125.97.210:/home/ext_vkrishna/f1 c:\temp"

$op.Output | Out-File c:\temp\scp.txt

$date = Get-Date

$week = (Get-WmiObject win32_localtime).weekinmonth

$format = $date.GetDateTimeFormats() | select -First 7 | select -Last 1

$ad = $format.Substring(1)

$path = "c:\temp\Device\weekly\$ad\splunk\"

Start-Process pscp.exe -ArgumentList ("-scp -r -pw Welcome123 ext_vkrishna@10.125.97.210:/home/ext_vkrishna/local3 c:\temp\$ad\splunk2\FIS3") -PassThru
#