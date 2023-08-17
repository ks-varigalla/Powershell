$pass = "W3Lc0m3#t0!nd!@"
$ip = "10.3.0.10"
$ip2 = "10.122.101.11"
$user = "hcladmin"
$ssh = New-SSHSession -ComputerName $ip -Credential $creds -ConnectionTimeout 300 -Force
$op1 = Invoke-SSHCommand -SSHSession $ssh -Command "configure terminal" -TimeOut 300 
$op2 = Invoke-SSHCommand -SSHSession $ssh -Command "ip http secure-server" #-TimeOut 300
$op5 = Invoke-SSHCommand -SSHSession $ssh -Command "exit" -TimeOut 300
$op3 = Invoke-SSHCommand -SSHSession $ssh -Command "copy running-config" -TimeOut 300
$op4 = Invoke-SSHCommand -SSHSession $ssh -Command "show running-config" -TimeOut 300
$stream = $ssh.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)
$stream.Write("show running-config")
$stream.Write("`n")

Invoke-SSHCommand -SessionId $ssh.SessionId 


