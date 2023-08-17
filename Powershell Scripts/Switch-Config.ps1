# Editing the Switch config file

$ip = "10.3.0.10"

$ssh = New-SSHSession -ComputerName $ip -Credential $creds -ConnectionTimeout 300 -Force

$stream = $ssh.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)

$stream.Write("configure terminal`n")

$stream.Write("no ip http server`n")

$stream.Write("no ip http secure-server`n")

$stream.write("line vty 0 4`n")

$stream.Write("transport input all`n")

$stream.Write("Exit`n")

$stream.Write("copy running-config startup-config`n")

$stream.Write(" `n")

$stream.Read()
#$stream.Close()
#$ssh.Disconnect()